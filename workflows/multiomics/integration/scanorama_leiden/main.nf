nextflow.enable.dsl=2

workflowDir = params.rootDir + "/workflows"
targetDir = params.rootDir + "/target/nextflow"

include { leiden } from targetDir + '/cluster/leiden/main.nf'
include { scanorama } from targetDir + '/integrate/scanorama/main.nf'
include { umap } from targetDir + '/dimred/umap/main.nf'
include { move_obsm_to_obs } from targetDir + '/metadata/move_obsm_to_obs/main.nf'
include { find_neighbors } from targetDir + '/neighbors/find_neighbors/main.nf'

include { readConfig; helpMessage; preprocessInputs; channelFromParams } from workflowDir + "/utils/WorkflowHelper.nf"
include { setWorkflowArguments; getWorkflowArguments; passthroughMap as pmap } from workflowDir + "/utils/DataflowHelper.nf"

config = readConfig("$workflowDir/multiomics/integration/scanorama_leiden/config.vsh.yaml")

workflow {
  helpMessage(config)

  channelFromParams(params, config)
    | view { "Input: $it" }
    | run_wf
    | view { "Output: $it" }
}

workflow run_wf {
  take:
  input_ch

  main:
  output_ch = input_ch
    | preprocessInputs("config": config)
    // split params for downstream components
    | setWorkflowArguments(
      scanorama: [
        "obsm_input": "obsm_input",
        "obs_batch": "obs_batch",
        "obsm_output": "obsm_output",
        "modality": "modality",
        "batch_size": "batch_size",
        "sigma": "sigma",
        "approx": "approx",
        "alpha": "alpha",
        "knn": "knn",
      ],
      neighbors: [
        "uns_output": "uns_neighbors",
        "obsp_distances": "obsp_neighbor_distances",
        "obsp_connectivities": "obsp_neighbor_connectivities",
        "obsm_input": "obsm_output",
        "modality": "modality"

      ],
      clustering: [
        "obsp_connectivities": "obsp_neighbor_connectivities",
        "obsm_name": "obs_cluster",
        "resolution": "leiden_resolution",
        "modality": "modality"

      ],
      umap: [ 
        "uns_neighbors": "uns_neighbors",
        "obsm_output": "obsm_umap",
        "modality": "modality"

      ],
      move_obsm_to_obs_leiden: [
        "obsm_key": "obs_cluster",
        "output": "output"
      ]
    )
    | getWorkflowArguments(key: "scanorama")
    | scanorama
    | getWorkflowArguments(key: "neighbors")
    | find_neighbors
    | getWorkflowArguments(key: "clustering")
    | leiden
    | getWorkflowArguments(key: "umap")
    | umap
    | getWorkflowArguments(key: "move_obsm_to_obs_leiden")
    | move_obsm_to_obs.run(
        args: [ output_compression: "gzip" ],     
        auto: [ publish: true ]
    )

    // remove splitArgs
    | map { tup ->
      tup.take(2) + tup.drop(3)
    }

  emit:
  output_ch
}

workflow test_wf {
  // allow changing the resources_test dir
  params.resources_test = params.rootDir + "/resources_test"

  // or when running from s3: params.resources_test = "s3://openpipelines-data/"
  testParams = [
    param_list: [
      [
        id: "foo",
        input: params.resources_test + "/pbmc_1k_protein_v3/pbmc_1k_protein_v3_mms.h5mu",
        layer: "log_normalized",
        leiden_resolution: [1, 0.25],
        output: "foo.final.h5mu"
      ]
    ]
  ]

  output_ch =
    channelFromParams(testParams, config)
    | view { "Input: $it" }
    | run_wf
    | view { output ->
      assert output.size() == 2 : "outputs should contain two elements; [id, file]"
      assert output[1].toString().endsWith(".h5mu") : "Output file should be a h5mu file. Found: ${output_list[1]}"
      "Output: $output"
    }
    | toList()
    | map { output_list ->
      assert output_list.size() == 1 : "output channel should contain 1 event"
      assert (output_list.collect({it[0]}) as Set).equals(["foo"] as Set): "Output ID should be same as input ID"
      assert (output_list.collect({it[1].getFileName().toString()}) as Set).equals(["foo.final.h5mu"] as Set)

    }
    //| check_format(args: {""}) // todo: check whether output h5mu has the right slots defined
}