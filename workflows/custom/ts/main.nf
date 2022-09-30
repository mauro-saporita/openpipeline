nextflow.enable.dsl=2

workflowDir = params.rootDir + "/workflows"
targetDir = params.rootDir + "/target/nextflow"

include { cellranger_mkfastq } from targetDir + "/demux/cellranger_mkfastq/main.nf"
include { cellranger_count } from targetDir + "/mapping/cellranger_count/main.nf"
include { cellranger_count_split } from targetDir + "/mapping/cellranger_count_split/main.nf"
include { cellbender_remove_background } from targetDir + "/correction/cellbender_remove_background/main.nf"
include { from_10xh5_to_h5mu } from targetDir + "/convert/from_10xh5_to_h5mu/main.nf"

include { readConfig; viashChannel; helpMessage } from workflowDir + "/utils/WorkflowHelper.nf"
include { setWorkflowArguments; getWorkflowArguments; passthroughMap as pmap } from workflowDir + "/utils/DataFlowHelper.nf"

config = readConfig("$workflowDir/ingestion/cellranger_mapping/config.vsh.yaml")

workflow {
  helpMessage(config)

  viashChannel(params, config)
    | view { "Input: $it" }
    | run_wf
    | view { "Output: $it" }
}

workflow run_wf {
  take:
  input_ch

  main:

  output_ch = input_ch
  
    // split params for downstream components
    | setWorkflowArguments(
      cellranger_count: [
        "input": "input",
        "expect_cells": "expect_cells",
        "chemistry": "chemistry",
        "secondary_analysis": "secondary_analysis",
        "generate_bam": "generate_bam",
        "include_introns": "include_introns"
      ],
      from_10xh5_to_h5mu: [ 
        "sample_id": "id",
        "output": "output_h5mu",
        "obs_sample_id": "obs_sample_id",
        "obsm_metrics": "obsm_metrics",
        "id_to_obs_names": "id_to_obs_names",
        "min_genes": "min_genes",
        "min_counts": "min_counts"
      ]
    )

    | getWorkflowArguments(key: "cellranger_count")
    | cellranger_count.run(auto: [ publish: true ])

    // split output dir into map
    | cellranger_count_split

    // run cellbender
    | pmap { id, data, split_args -> 
      new_data = [ input: data.raw_h5 ]
      new_split_args.copy()
      new_split_args.from_10xh5_to_h5mu.input_metrics_summary = data.metrics_summary

      [ id, new_data, new_split_args]
    }
    | cellbender_remove_background

    // convert to h5mu
    | pmap { id, data, split_args -> [ id, [ input: data.output ], split_args ]}
    | getWorkflowArguments(key: "from_10xh5_to_h5mu")
    | from_10xh5_to_h5mu.run(auto: [ publish: true ])

    // return output map
    | pmap { id, h5mu, data ->
      [ id, data + [h5mu: h5mu] ]
    }

  emit:
  output_ch
}


workflow test_wf {
  // allow changing the resources_test dir
  params.resources_test = params.rootDir + "/resources_test"

  // or when running from s3: params.resources_test = "s3://openpipelines-data/"
  testParams = [
    id: "foo",
    input: params.resources_test + "/cellranger_tiny_fastq/cellranger_tiny_fastq",
    reference: params.resources_test + "/cellranger_tiny_fastq/cellranger_tiny_ref"
  ]

  output_ch =
    viashChannel(testParams, config)
    | view { "Input: $it" }
    | run_wf
    | view { output ->
      assert output.size() == 2 : "outputs should contain two elements; [id, out]"
      assert output[1] instanceof Map : "Output should be a Map."
      // todo: check whether output dir contains fastq files
      "Output: $output"
    }
    | toList()
    | map { output_list ->
      assert output_list.size() == 1 : "output channel should contain one event"
      assert output_list[0][0] == "foo" : "Output ID should be same as input ID"
    }
    //| check_format(args: {""}) // todo: check whether output h5mu has the right slots defined
}