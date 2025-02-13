# openpipelines 0.10.0

## BREAKING CHANGES

* `workflows/full_pipeline`: removed `--prot_min_fraction_mito` and `--prot_max_fraction_mito` (PR #451)

* `workflows/rna_multisample` and `workflows/prot_multisample`: Removed concatenation from these pipelines. The input for these pipelines is now a single mudata file that contains data for multiple samples. If you wish to use this pipeline on multiple single-sample mudata files, you can use the `dataflow/concat` components on them first. This also implies that the ability to add ids to multiple single-sample mudata files prior to concatenation is no longer required, hence the removal of `--add_id_to_obs`, `--sample_id`, `--add_id_obs_output`,  and `--add_id_make_observation_keys_unique` (PR #475).

* The `scvi` pipeline was renamed to `scvi_leiden` because `leiden` clustering was added to the pipeline (PR #499).

## MAJOR CHANGES

* Several components: update anndata to 0.9.3 and mudata to 0.2.3 (PR #423).

## MINOR CHANGES

* `full_pipeline`: default value for `--var_qc_metrics` is now the combined values specified for `--mitochondrial_gene_regex` and `--filter_with_hvg_var_output`.

* `dataflow/concat`: reduce memory consumption by only reading one modality at the same time (PR #474).

* Components that use CellRanger, BCL Convert or bcl2fastq: updated from Ubuntu 20.04 to Ubuntu 22.04 (PR #494).

* Components that use CellRanger: updated Picard to 2.27.5 (PR #494).

* `interprete/liana`: Update lianapy to 0.1.9 (PR #497).

* `qc/multiqc`: add unittests (PR #502).

* `reference/build_cellranger_reference`: add unit tests (PR #506).

* `reference/build_bd_rhapsody_reference`: add unittests (PR #504).

## NEW FUNCTIONALITY

* `integrate/scvi`: Add `--n_hidden_nodes`, `--n_dimensions_latent_space`, `--n_hidden_layers`, `--dropout_rate`, `--dispersion`, `--gene_likelihood`, `--use_layer_normalization`, `--use_batch_normalization`, `--encode_covariates`, `--deeply_inject_covariates` and `--use_observed_lib_size` parameters.

* `filter/filter_with_counts`: add `--var_name_mitochondrial_genes` argument to store a boolean array corresponding the detected mitochondrial genes.

* `full_pipeline` and `rna_singlesample` pipelines: add `--var_name_mitochondrial_genes`,  `--var_gene_names` and `--mitochondrial_gene_regex` arguments to specify mitochondrial gene detection behaviour.

* `integrate/scvi`: Add `--obs_labels`, `--obs_size_factor`, `--obs_categorical_covariate` and `--obs_continuous_covariate` arguments (PR #496).

* Added `var_qc_metrics_fill_na_value` argument to `calculate_qc_metrics` (PR #477).

* Added `multiomics/multisample` pipeline to run multisample processing followed by the integration setup. It is considered an entrypoint into the full pipeline which skips the single-sample processing. The idea is to allow a a re-run of these steps after a sample has already been processed by the `full_pipeline`. Keep in mind that samples that are provided as input to this pipeline are processed separately and are not concatenated. Hence, the input should be a concatenated sample (PR #475). 

* Added `multiomics/integration/bbknn_leiden` workflow. (PR #456).

* `workflows/prot_multisample` and `workflows/full_pipelines`: add basic QC statistics to prot modality (PR #485).

* `mapping/cellranger_multi`: Add tests for the mapping of Crispr Guide Capture data (PR #494).

* `convert/from_cellranger_multi_to_h5mu`: add `perturbation_efficiencies_by_feature` and `perturbation_efficiencies_by_feature` information to .uns slot of `gdo` modality (PR #494).

* `convert/from_cellranger_multi_to_h5mu`: add `feature_reference` information to the MuData object. Information is split between the modalities. For example `CRISPR Guide Capture` information if added to the `.uns` slot of the `gdo` modality, while `Antibody Capture` information is added to the .uns slot of `prot` (PR #494).

* `workflows/full_pipeline`: Add `pca_overwrite` argument (PR #511).

## BUG FIXES

* Fix an issue with `workflows/multiomics/scanorama_leiden` where the `--output` argument doesn't work as expected (PR #509).

* Fix an issue with `workflows/full_pipeline` not correctly caching previous runs (PR #460).

* Fix incorrect namespaces of the integration pipelines (PR #464).

* Fix an issue in several workflows where the `--output` argument would not work (PR #476).

* `integration/harmony_leiden` and `integration/scanorama_leiden`: Fix an issue where the prefix of the columns that store the leiden clusters was hardcoded to `leiden`, instead of adapting to the value for `--obs_cluster` (PR #482). 

* `velocity/velocyto`: Resolve symbolic link before checking whether the transcriptome is a gzip (PR #484).

* `workflows/integration/scanorama_leiden`: fix an issue where `--obsm_input`, --obs_batch`, `--batch_size`, `--sigma`, `--approx`, `--alpha` and `-knn` were not working beacuse they were not passed through to the scanorama component (PR #487).

* `workflows/integration/scanorama_leiden`: fix leiden being calculated on the wrong embedding because the `--obsm_input` argument was not correctly set to the output embedding of scanorama (PR #487).

* `mapping/cellranger_multi`: Fix and issue where modalities did not have the proper name (PR #494).

* `metadata/add_uns_to_obs`: Fix `KeyError: 'ouput_compression'` error (PR #501).

# openpipelines 0.9.0

## BREAKING CHANGES

Running the integration in the `full_pipeline` deemed to be impractical because a plethora of integration methods exist, which in turn interact with other functionality (like clustering). This generates a large number of possible usecases which one pipeline cannot cover in an easy manner. Instead, each integration methods will be split into its separate pipeline, and the `full_pipeline` will prepare for integration by performing steps that are required by many integration methods. Therefore, the following changes were performed:

  * `workflows/full_pipeline`: `harmony` integration and `leiden` clustering are removed from the pipeline.

  * Added `initialize_integration` to run calculations that output information commonly required by the integration methods. This pipeline runs PCA, nearest neighbours and UMAP. This pipeline is run as a subpipeline at the end of `full_pipeline`.

  * Added `leiden_harmony` integration pipeline: run harmony integration followed by neighbour calculations and leiden clustering. Also runs umap on the result.

  * Removed the `integration` pipeline.

The old behavior of the `full_pipeline` can be obtained by running `full_pipeline` followed by the `leiden_harmony` pipeline.

* The `crispr` and `hashing` modalities have been renamed to `gdo` and `hto` respectively (PR #392).

* Updated Viash to 0.7.4 (PR #390).

* `cluster/leiden`: Output is now stored into `.obsm` instead of `.obs` (PR #431).

## NEW FUNCTIONALITY

* `cluster/leiden` and `integration/harmony_leiden`: allow running leiden multiple times with multiple resolutions (PR #431).

* `workflows/full_pipeline`: PCA, nearest neighbours and UMAP are now calculated for the `prot` modality (PR #396).

* `transform/clr`: added `output_layer` argument (PR #396).

* `workflows/integration/scvi`: Run scvi integration followed by neighbour calculations and run umap on the result (PR #396).

* `mapping/cellranger_multi` and `workflows/ingestion/cellranger_multi`: Added `--vdj_inner_enrichment_primers` argument (PR #417).

* `metadata/move_obsm_to_obs`: Move a matrix from an `.obsm` slot into `.obs` (PR #431).

* `integrate/scvi` validity checks for non-normalized input, obs and vars in order to proceed to training (PR #429).

* `schemas`: Added schema files for authors (PR #436).

* `schemas`: Added schema file for Viash configs (PR #436).

* `schemas`: Refactor author import paths (PR #436).

* `schemas`: Added schema file for file format specification files (PR #437).

* `query/cellxgene_census`: Query Cellxgene census component and save the results to a MuData file. (PR #433).

## MAJOR CHANGES

* `report/mermaid`: Now used `mermaid-cli` to generate images instead of creating a request to `mermaid.ink`. New `--output_format`, `--width`, `--height` and  `--background_color` arguments were added (PR #419).

* All components that used `python` as base container: use `slim` version to reduce container image size (PR #427).

## MINOR CHANGES

* `integrate/scvi`: update scvi to 1.0.0 (PR #448)

* `mapping/multi_star`: Added `--min_success_rate` which causes component to fail when the success rate of processed samples were successful (PR #408).

* `correction/cellbender_remove_background` and `transform/clr`: update muon to 0.1.5 (PR #428)

* `ingestion/cellranger_postprocessing`: split integration tests into several workflows (PR #425).

* `schemas`: Add schema file for author yamls (PR #436).

* `mapping/multi_star`, `mapping/star_build_reference` and `mapping/star_align`: update STAR from 2.7.10a to 2.7.10b (PR #441).

## BUG FIXES

* `annotate/popv`: Fix concat issue when the input data has multiple layers (#395, PR #397).

* `annotate/popv`: Fix indexing issue when MuData object contain non overlapping modalities (PR #405).

* `mapping/multi_star`: Fix issue where temp dir could not be created when group_id contains slashes (PR #406).

* `mapping/multi_star_to_h5mu`: Use glob to look for count files recursively (PR #408).

* `annotate/popv`: Pin `PopV`, `jax` and `jaxlib` versions (PR #415).

* `integrate/scvi`: the max_epochs is no longer required since it has a default value (PR #396).

* `workflows/full_pipeline`: fix `make_observation_keys_unique` parameter not being correctly passed to the `add_id` component, causing `ValueError: Observations are not unique across samples` during execution of the `concat` component (PR #422).

* `annotate/popv`: now sets `aprox` to `False` to avoid using `annoy` in scanorama because it fails on processors that are missing the AVX-512 instruction sets, causing `Illegal instruction (core dumped)`.

* `workflows/full_pipeline`: Avoid adding sample names to observation ids twice (PR #457). 

# openpipelines 0.8.0

## BREAKING CHANGES

* `workflows/full_pipeline`: Renamed inconsistencies in argument naming (#372):
  - `rna_min_vars_per_cell` was renamed to `rna_min_genes_per_cell`
  - `rna_max_vars_per_cell` was renamed to `rna_max_genes_per_cell`
  - `prot_min_vars_per_cell` was renamed to `prot_min_proteins_per_cell`
  - `prot_max_vars_per_cell` was renamed to `prot_max_proteins_per_cell`

* `velocity/scvelo`: bump anndata from <0.8 to 0.9.

## NEW FUNCTIONALITY

* Added an extra label `veryhighmem` mostly for `cellranger_multi` with a large number of samples.

* Added `multiomics/prot_multisample` pipeline.

* Added `clr` functionality to `prot_multisample` pipeline.

* Added `interpret/lianapy`: Enables the use of any combination of ligand-receptor methods and resources, and their consensus.

* `filter/filter_with_scrublet`: Add `--allow_automatic_threshold_detection_fail`: when scrublet fails to detect doublets, the component will now put `NA` in the output columns.

* `workflows/full_pipeline`: Allow not setting the sample ID to the .obs column of the MuData object.

* `workflows/rna_multisample`: Add the ID of the sample to the .obs column of the MuData object.

* `correction/cellbender_remove_background`: add `obsm_latent_gene_encoding` parameter to store the latent gene representation.

## BUG FIXES

* `transform/clr`: fix anndata object instead of matrix being stored as a layer in output `MuData`, resulting in `NoneTypeError` object after reading the `.layers` back in.

* `dataflow/concat` and `dataflow/merge`: fixed a bug where boolean values were cast to their string representation.

* `workflows/full_pipeline`: fix running pipeline with `-stub`.

* Fixed an issue where passing a remote file URI (for example `http://` or `s3://`) as `param_list` caused `No such file` errors.

* `workflows/full_pipeline`: Fix incorrectly named filtering arguments (#372).

* `integrate/scvi`: Fix bug when subsetting using the `var_input` argument (PR #385).
* 
* `correction/cellbender_remove_background`: add `obsm_latent_gene_encoding` parameter to store the latent gene representation.

## MINOR CHANGES

* `integrate/scarches`, `integrate/scvi` and `correction/cellbender_remove_background`: Update base container to `nvcr.io/nvidia/pytorch:22.12-py3`

* `integrate/scvi`: add `gpu` label for nextflow platform.

* `integrate/scvi`: use cuda enabled `jax` install.

* `convert/from_cellranger_multi_to_h5mu`, `dataflow/concat` and `dataflow/merge`: update pandas to 2.0.0

* `dataflow/concat` and `dataflow/merge`: Boolean and integer columns are now represented by the `BooleanArray` and `IntegerArray` dtypes in order to allow storing `NA` values.

* `interpret/lianapy`: use the latest development release (commit 11156ddd0139a49dfebdd08ac230f0ebf008b7f8) of lianapy in order to fix compatibility with numpy 1.24.x.

* `filter/filter_with_hvg`: Add error when specified input layer cannot be found in input data.

* `workflows/multiomics/full_pipeline`: publish the output from sample merging to allow running different integrations.

* CI: Remove various unused software libraries from runner image in order to avoid `no space left on device` (PR #425, PR #447).

# openpipelines 0.7.1

## NEW FUNCTIONALITY

* `integrate/scvi`: use `nvcr.io/nvidia/pytorch:22.09-py3` as base container to enable GPU acceleration.

* `integrate/scvi`: add `--model_output` to save model.

* `workflows/ingestion/cellranger_mapping`: Added `output_type` to output the filtered Cell Ranger data as h5mu, not the converted raw 10xh5 output.

* Several components:  added `--output_compression` component to set the compression of output .h5mu files.

* `workflows/full_pipeline` and `workflows/integration`: Added `leiden_resolution` argument to control the coarseness of the clustering.

* Added `--rna_theta` and `--rna_harmony_theta` to full and integration pipeline respectively in order to tune the diversity clustering penalty parameter for harmony integration.

* `dimred/pca`: fix `variance` slot containing a second copy of the variance ratio matrix and not the variances.

## BUG FIXES

* `mapping/cellranger_multi`: Fix an issue where using a directory as value for `--input` would cause `AttributeError`.

* `workflows/integration`: `init_pos` is no longer set to the integration layer (e.g. `X_pca_integrated`).

## MINOR CHANGES

* `integration` and `full` workflows: do not run harmony integration when `obs_covariates` is not provided.

* Add `highmem` label to `dimred/pca` component.

* Remove disabled `convert/from_csv_to_h5mu` component.

* Update to Viash 0.7.1.

* Several components: update to scanpy 1.9.2

* `process_10xh5/filter_10xh5`: speed up build by using `eddelbuettel/r2u:22.04` base container.

## MAJOR CHANGES

* `dataflow/concat`: Renamed `--compression` to `--output_compression`.

# openpipelines 0.7.0

## MAJOR CHANGES

* Removed `bin` folder. As of viash 0.6.4, a `_viash.yaml` file can be included in the root of a repository to set common viash options for the project.
These options were previously covered in the `bin/init` script, but this new feature of viash makes its use unnecessary. The `viash` and `nextlow` should now be installed in a directory that is included in your `$PATH`.

## MINOR CHANGES

* `filter/do_filter`: raise an error instead of printing a warning when providing a column for `var_filer` or `obs_filter` that doesn't exist.

## BUG FIXES

* `workflows/full_pipeline`: Fix setting .var output column for filter_with_hvg.

* Fix running `mapping/cellranger_multi` without passing all references.

* `filter/filter_with_scrublet`: now sets `use_approx_neighbors` to `False` to avoid using `annoy` because it fails on processors that are missing the AVX-512 instruction sets.

* `workflows`: Updated `WorkflowHelper` to newer version that allows applying defaults when calling a subworkflow from another workflow.

* Several components: pin matplotlib to <3.7 to fix scanpy compatibility (see https://github.com/scverse/scanpy/issues/2411).  

* `workflows`: fix a bug when running a subworkflow from a workflow would cause the parent config to be read instead of the subworklow config.

* `correction/cellbender_remove_background`: Fix description of input for cellbender_remove_background.

* `filter/do_filter`: resolved an issue where the .obs column instead of the .var column was being logged when filtering using the .var column.

* `workflows/rna_singlesample` and `workflows/prot_singlesample`: Correctly set var and obs columns while filtering with counts.

* `filter/do_filter`: removed the default input value for `var_filter` argument.

* `workflows/full_pipeline` and `workflows/integration`: fix PCA not using highly variable genes filter.

# openpipelines 0.6.2

## NEW FUNCTIONALITY

* `workflows/full_pipeline`: added `filter_with_hvg_obs_batch_key` argument for batched detection of highly variable genes.

* `workflows/rna_multisample`: added `filter_with_hvg_obs_batch_key`, `filter_with_hvg_flavor` and `filter_with_hvg_n_top_genes` arguments.

* `qc/calculate_qc_metrics`: Add basic statistics: `pct_dropout`, `num_zero_obs`, `obs_mean` and `total_counts` are added to .var. `num_nonzero_vars`, `pct_{var_qc_metrics}`, `total_counts_{var_qc_metrics}`, `pct_of_counts_in_top_{top_n_vars}_vars` and `total_counts` are included in .obs

* `workflows/multiomics/rna_multisample` and `workflows/multiomics/full_pipeline`: add `qc/calculate_qc_metrics` component to workflow.

* `workflows/multiomics/prot_singlesample`: Processing unimodal single-sample CITE-seq data.

* `workflows/multiomics/rna_singlesample` and `workflows/multiomics/full_pipeline`: Add filtering arguments to pipeline.

## MINOR CHANGES

* `convert/from_bdrhap_to_h5mu`: bump R version to 4.2.

* `process_10xh5/filter_10xh5`: bump R version to 4.2.

* `dataflow/concat`: include path of file in error message when reading a mudata file fails.

* `mapping/cellranger_multi`: write cellranger console output to a `cellranger_multi.log` file.

## BUG FIXES

* `mapping/htseq_count_to_h5mu`: Fix a bug where reading in the gtf file caused `AttributeError`. 

* `dataflow/concat`: the `--input_id` is no longer required when `--mode` is not `move`.

* `filter/filter_with_hvg`: does no longer try to use `--varm_name` to set non-existant metadata when running with `--flavor seurat_v3`, which was causing `KeyError`.

* `filter/filter_with_hvg`: Enforce that `n_top_genes` is set when `flavor` is set to 'seurat_v3'.

* `filter/filter_with_hvg`: Improve error message when trying to use 'cell_ranger' as `flavor` and passing unfiltered data.

* `mapping/cellranger_multi` now applies `gex_chemistry`, `gex_secondary_analysis`, `gex_generate_bam`, `gex_include_introns` and `gex_expect_cells`.

# openpipeline 0.6.1

## NEW FUNCTIONALITY

* `mapping/multi_star`: A parallellized version of running STAR (and HTSeq).

* `mapping/multi_star_to_h5mu`: Convert the output of `multi_star` to a h5mu file.

## BUG FIXES

* `filter/filter_with_counts`: Fix an issue where mitochrondrial genes were being detected in .var_names, which contain ENSAMBL IDs instead of gene symbols in the pipelines. Solution was to create a `--var_gene_names` argument which allows selecting a .var column to check using a regex (`--mitochondrial_gene_regex`).

* `dataflow/concat`, `report/mermaid`, `transform/clr`: Don't forget to exit with code returned by pytest.
# openpipeline 0.6.0

## NEW FUNCTIONALITY

* `workflows/full_pipeline`: add `filter_with_hvg_var_output` argument.

* `dimred/pca`: Add `--overwrite` and `--var_input` arguments.

* `tranform/clr`: Perform CLR normalization on CITE-seq data.

* `workflows/ingestion/cellranger_multi`: Run Cell Ranger multi and convert the output to .h5mu.

* `filter/remove_modality`: Remove a single modality from a MuData file.

* `mapping/star_align`: Align `.fastq` files using STAR.

* `mapping/star_align_v273a`: Align `.fastq` files using STAR v2.7.3a.

* `mapping/star_build_reference`: Create a STAR reference index.

* `mapping/cellranger_multi`: Align fastq files using Cell Ranger multi.

* `mapping/samtools_sort`: Sort and (optionally) index alignments.

* `mapping/htseq_count`: Quantify gene expression for subsequent testing for differential expression.

* `mapping/htseq_count_to_h5mu`: Convert one or more HTSeq outputs to a MuData file.

* Added from `convert/from_cellranger_multi_to_h5mu` component.

## MAJOR CHANGES

* `convert/from_velocyto_to_h5mu`: Moved to `velocity/velocyto_to_h5mu`.
  It also now accepts an optional `--input_h5mu` argument, to allow directly reading
  the RNA velocity data into a `.h5mu` file containing the other modalities.

* `resources_test/cellranger_tiny_fastq`: Include RNA velocity computations as part of
  the script.

* `mapping/cellranger_mkfastq`: remove --memory and --cpu arguments as (resource management is automatically provided by viash).

## MINOR CHANGES

* Several components: use `gzip` compression for writing .h5mu files.

* Default value for `obs_covariates` argument of full pipeline is now `sample_id`.

* Set the `tag` directive of all Nextflow components to '$id'.

## BUG FIXES

* Keep data for modalities that are not specifically enabled when running full pipeline.

* Fix many components thanks to Viash 0.6.4, which causes errors to be 
  thrown when input and output files are defined but not found.


# openpipeline 0.5.1

## BREAKING CHANGES

* `reference/make_reference`: Input files changed from `type: string` to `type: file` to allow Nextflow to cache the input files fetched from URL.

* several components (except `from_h5ad_to_h5mu`): the `--modality` arguments no longer accept multiple values.

* Remove outdated `resources_test_scripts`.

* `convert/from_h5mu_to_seurat`: Disabled because MuDataSeurat is currently broken, see [https://github.com/PMBio/MuDataSeurat/issues/9](PMBio/MuDataSeurat#9).

* `integrate/harmony`: Disabled because it is currently not functioning and the alternative, harmonypy, is used in the workflows.

* `dataflow/concat`: Renamed --sample_names to --input_id and moved the ability to add sample id and to join the sample ids with the observation names to `metadata/add_id`

* Moved `dataflow/concat`, `dataflow/merge` and `dataflow/split_modalities` to a new namespace: `dataflow`.

* Moved `workflows/conversion/conversion` to `workflows/ingestion/conversion`

## NEW FUNCTIONALITY

* `metadata/add_id`: Add an id to a column in .obs. Also allows joining the id to the .obs_names.

* `workflows/ingestion/make_reference`: A generic component to build a transcriptomics reference into one of many formats.

* `integrate/scvi`: Performs scvi integration.

* `integrate/add_metadata`: Add a csv containing metadata to the .obs or .var field of a mudata file.

* `DataflowHelper.nf`: Added `passthroughMap`. Usage:

  ```groovy
  include { passthroughMap as pmap } from "./DataflowHelper.nf"
  
  workflow {
    Channel.fromList([["id", [input: "foo"], "passthrough"]])
      | pmap{ id, data ->
        [id, data + [arg: 10]]
      }
  }
  ```
  Note that in the example above, using a regular `map` would result in an exception being thrown,
  that is, "Invalid method invocation `call` with arguments".

  A synonymous of doing this with a regular `map()` would be:
  ```groovy
  workflow {
    Channel.fromList([["id", [input: "foo"], "passthrough"]])
      | map{ tup ->
        def (id, data) = tup
        [id, data + [arg: 10]] + tup.drop(2)
      }
  }
  ```

* `correction/cellbender_remove_background`: Eliminating technical artifacts from high-throughput single-cell RNA sequencing data.

* `workflows/ingestion/cellranger_postprocessing`: Add post-processing of h5mu files created from Cell Ranger data.

* `annotate/popv`: Performs popular major vote cell typing on single cell sequence data.

## MAJOR CHANGES

* `workflows/utils/DataflowHelper.nf`: Added helper functions `setWorkflowArguments()` and `getWorkflowArguments()` to split the data field of a channel event into a hashmap. Example usage:
  ```groovy
  | setWorkflowArguments(
    pca: [ "input": "input", "obsm_output": "obsm_pca" ]
    integration: [ "obs_covariates": "obs_covariates", "obsm_input": "obsm_pca" ]
  )
  | getWorkflowArguments("pca")
  | pca
  | getWorkflowArguments("integration")
  | integration
  ```

* `mapping/cellranger_count`: Allow passing both directories as well as individual fastq.gz files as inputs.

* `convert/from_10xh5_to_h5mu`: Allow reading in QC metrics, use gene ids as `.obs_names` instead of gene symbols.

* `workflows/conversion`: Update pipeline to use the latest practices and to get it to a working state.

## MINOR CHANGES

* `dimred/umap`: Streamline UMAP parameters by adding `--obsm_output` parameter to allow choosing the output `.obsm` slot.

* `workflows/multiomics/integration`: Added arguments for tuning the various output slots of the integration pipeline, namely `--obsm_pca`, `--obsm_integrated`, `--uns_neighbors`, `--obsp_neighbor_distances`, `--obsp_neighbor_connectivities`, `--obs_cluster`, `--obsm_umap`.

* Switch to Viash 0.6.1.

* `filter/subset_h5mu`: Add `--modality` argument, export to VDSL3, add unit test.

* `dataflow/split_modalities`: Also output modality types in a separate csv.

## BUG FIXES

* `convert/from_bd_to_10x_molecular_barcode_tags`: Replaced UTF8 characters with ASCII. OpenJDK 17 or lower might throw the following exception when trying to read a UTF8 file: `java.nio.charset.MalformedInputException: Input length = 1`.

* `dataflow/concat`: Overriding sample name in .obs no longer raises `AttributeError`.

* `dataflow/concat`: Fix false positives when checking for conflicts in .obs and .var when using `--mode move`.

# openpipeline 0.5.0

Major redesign of the integration and multiomic workflows. Current list of workflows:

* `ingestion/bd_rhapsody`: A generic pipeline for running BD Rhapsody WTA or Targeted mapping, with support for AbSeq, VDJ and/or SMK.

* `ingestion/cellranger_mapping`: A pipeline for running Cell Ranger mapping.

* `ingestion/demux`: A generic pipeline for running bcl2fastq, bcl-convert or Cell Ranger mkfastq.

* `multiomics/rna_singlesample`: Processing unimodal single-sample RNA transcriptomics data.

* `multiomics/rna_multisample`: Processing unimodal multi-sample RNA transcriptomics data.

* `multiomics/integration`: A pipeline for demultiplexing multimodal multi-sample RNA transcriptomics data.

* `multiomics/full_pipeline`: A pipeline to analyse multiple multiomics samples.

## BREAKING CHANGES

* Many components: Renamed `.var["gene_ids"]` and `.var["feature_types"]` to `.var["gene_id"]` and `.var["feature_type"]`.

## DEPRECATED

* `convert/from_10xh5_to_h5ad` and `convert/from_bdrhap_to_h5ad`: Removed h5ad based components.

* `mapping/bd_rhapsody_wta` and `workflows/ingestion/bd_rhapsody_wta`: Deprecated in favour for more generic `mapping/bd_rhapsody` and `workflows/ingestion/bd_rhapsody` pipelines.

* `convert/from_csv_to_h5mu`: Disable until it is needed again.

* `dataflow/concat`: Deprecated `"concat"` option for `--other_axis_mode`.

## NEW COMPONENTS

* `graph/bbknn`: Batch balanced KNN.

* `transform/scaling`: Scale data to unit variance and zero mean.

* `mapping/bd_rhapsody`: Added generic component for running the BD Rhapsody WTA or Targeted analysis, with support for AbSeq, VDJ and/or SMK.

* `integrate/harmony` and `integrate/harmonypy`: Run a Harmony integration analysis (R-based and Python-based, respectively).

* `integrate/scanorama`: Use Scanorama to integrate different experiments.

* `reference/make_reference`: Download a transcriptomics reference and preprocess it (adding ERCC spikeins and filtering with a regex).

* `reference/build_bdrhap_reference`: Compile a reference into a STAR index in the format expected by BD Rhapsody.

## NEW WORKFLOWS

* `workflows/ingestion/bd_rhapsody`: Added generic workflow for running the BD Rhapsody WTA or Targeted analysis, with support for AbSeq, VDJ and/or SMK.

* `workflows/multiomics/full_pipeline`: Implement pipeline for processing multiple multiomics samples.

## NEW FUNCTIONALITY

* `convert/from_bdrhap_to_h5mu`: Added support for being able to deal with WTA, Targeted, SMK, AbSeq and VDJ data.

* `dataflow/concat`: Added `"move"` option to `--other_axis_mode`, which allows merging `.obs` and `.var` by only keeping elements of the matrices which are the same in each of the samples, moving the conflicting values to `.varm` or `.obsm`.

## MAJOR CHANGES

* Multiple components: Update to anndata 0.8 with mudata 0.2.0. This means that the format of the `.h5mu` files have changed.

* `multiomics/rna_singlesample`: Move transformation counts into layers instead of overwriting `.X`.

* Updated to Viash 0.6.0.

## MINOR CHANGES

* `velocity/velocyto`: Allow configuring memory and parallellisation.

* `cluster/leiden`: Add `--obsp_connectivities` parameter to allow choosing the output slot.

* `workflows/multiomics/rna_singlesample`, `workflows/multiomics/rna_multisample` and `workflows/multiomics/integration`: Allow choosing the output paths.

* `neighbors/bbknn` and `neighbors/find_neighbors`: Add parameters for choosing the input/output slots.

* `dimred/pca` and `dimred/umap`: Add parameters for choosing the input/output slots.

* `dataflow/concat`: Optimize concat performance by adding multiprocessing and refactoring functions.

* `workflows/multimodal_integration`: Add `obs_covariates` argument to pipeline.

## BUG FIXES

* Several components: Revert using slim versions of containers because they do not provide the tools to run nextflow with trace capabilities.

* `dataflow/concat`: Fix an issue where joining boolean values caused `TypeError`.

* `workflows/multiomics/rna_multisample`, `workflows/multiomics/rna_singlesample` and `workflows/multiomics/integration`: Use nextflow trace reporting when running integration tests.


# openpipeline 0.4.1

## BUG FIXES

* `workflows/ingestion/bd_rhapsody_wta`: use ':' as a seperator for multiple input files and fix integration tests.

## MINOR CHANGES

* Several components: pin mudata and scanpy dependencies so that anndata version <0.8.0 is used.

# openpipeline 0.4.0

## NEW FUNCTIONALITY

* `convert/from_bdrhap_to_h5mu`: Merge one or more BD rhapsody outputs into an h5mu file.

* `dataflow/split_modalities`: Split the modalities from a single .h5mu multimodal sample into seperate .h5mu files. 

* `dataflow/concat`: Combine data from multiple samples together.

## MINOR CHANGES

* `mapping/bd_rhapsody_wta`: Update to BD Rhapsody 1.10.1.

* `mapping/bd_rhapsody_wta`: Add parameters for overriding the minimum RAM & cores. Add `--dryrun` parameter.

* Switch to Viash 0.5.14.

* `convert/from_bdrhap_to_h5mu`: Update to BD Rhapsody 1.10.1.

* `resources_test/bdrhap_5kjrt`: Add subsampled BD rhapsody datasets to test pipeline with.

* `resources_test/bdrhap_ref_gencodev40_chr1`: Add subsampled reference to test BD rhapsody pipeline with.

* `dataflow/merge`: Merge several unimodal .h5mu files into one multimodal .h5mu file.

* Updated several python docker images to slim version.

* `mapping/cellranger_count_split`: update container from ubuntu focal to ubuntu jammy

* `download/sync_test_resources`: update AWS cli tools from 2.7.11 to 2.7.12 by updating docker image

* `download/download_file`: now uses bash container instead of python.

* `mapping/bd_rhapsody_wta`: Use squashed docker image in which log4j issues are resolved.

## BUG FIXES

* `workflows/utils/WorkflowHelper.nf`: Renamed `utils.nf` to `WorkflowHelper.nf`.

* `workflows/utils/WorkflowHelper.nf`: Fix error message when required parameter is not specified.

* `workflows/utils/WorkflowHelper.nf`: Added helper functions:
  - `readConfig`: Read a Viash config from a yaml file.
  - `viashChannel`: Create a channel from the Viash config and the params object.
  - `helpMessage`: Print a help message and exit.

* `mapping/bd_rhapsody_wta`: Update picard to 2.27.3.

## DEPRECATED

* `convert/from_bdrhap_to_h5ad`: Deprecated in favour for `convert/from_bdrhap_to_h5mu`.

* `convert/from_10xh5_to_h5ad`: Deprecated in favour for `convert/from_10xh5_to_h5mu`.

# openpipeline 0.3.1

## NEW FUNCTIONALITY

* `bin/port_from_czbiohub_utilities.sh`: Added helper script to import components and pipelines from `czbiohub/utilities`

Imported components from `czbiohub/utilities`:

* `demux/cellranger_mkfastq`: Demultiplex raw sequencing data.

* `mapping/cellranger_count`: Align fastq files using Cell Ranger count.

* `mapping/cellranger_count_split`: Split 10x Cell Ranger output directory into separate output fields.

Imported workflows from `czbiohub/utilities`:

* `workflows/1_ingestion/cellranger`: Use Cell Ranger to preprocess 10x data.

* `workflows/1_ingestion/cellranger_demux`: Use cellranger demux to demultiplex sequencing BCL output to FASTQ.

* `workflows/1_ingestion/cellranger_mapping`: Use cellranger count to align 10x fastq files to a reference.


## MINOR CHANGES

* Fix `interactive/run_cirrocumulus` script raising `NotImplementedError` caused by using `MutData.var_names_make_unique()` 
on each modality instead of on the whole `MuData` object.

* Fix `transform/normalize_total` and `interactive/run_cirrocumulus` component build missing a hdf5 dependency.

* `interactive/run_cellxgene`: Updated container to ubuntu:focal because it contains python3.6 but cellxgene dropped python3.6 support.

* `mapping/bd_rhapsody_wta`: Set `--parallel` to true by default.

* `mapping/bd_rhapsody_wta`: Translate Bash script into Python.

* `download/sync_test_resources`: Add `--dryrun`, `--quiet`, and `--delete` arguments.

* `convert/from_h5mu_to_seurat`: Use `eddelbuettel/r2u:22.04` docker container in order to speed up builds by downloading precompiled R packages.

* `mapping/cellranger_count`: Use 5Gb for testing (to adhere to github CI runner memory constraints).

* `convert/from_bdrhap_to_h5ad`: change test data to output from `mapping/bd_rhapsody_wta` after reducing the BD Rhapsody test data size.

* Various `config.vsh.yaml`s: Renamed `values:` to `choices:`.

* `download/download_file` and `transfer/publish`: Switch base container from `bash:5.1` to `python:3.10`.

* `mapping/bd_rhapsody_wta`: Make sure procps is installed.

## BUG FIXES

* `mapping/bd_rhapsody_wta`: Use a smaller test dataset to reduce test time and make sure that the Github Action runners do not run out of disk space.

* `download/sync_test_resources`: Disable the use of the Amazon EC2 instance metadata service to make script work on Github Actions runners.

* `convert/from_h5mu_to_seurat`: Fix unit test requiring Seurat by using native R functions to test the Seurat object instead.

* `mapping/cellranger_count` and `bcl_demus/cellranger_mkfastq`: cellranger uses the `--parameter=value` formatting instead of `--parameter value` to set command line arguments.

* `mapping/cellranger_count`: `--nosecondary` is no longer always applied.

* `mapping/bd_rhapsody_wta`: Added workaround for bug in Viash 0.5.12 where triple single quotes are incorrectly escaped (viash-io/viash#139).

## DEPRECATED

* `bcl_demux/cellranger_mkfastq`: Duplicate of `demux/cellranger_mkfastq`.

# openpipeline 0.3.0

* Add `tx_processing` pipeline with following components:
  - `filter_with_counts`
  - `filter_with_scrublet`
  - `filter_with_hvg`
  - `do_filter`
  - `normalize_total`
  - `regress_out`
  - `log1p`
  - `pca`
  - `find_neighbors`
  - `leiden`
  - `umap`

# openpipeline 0.2.0

## NEW FUNCTIONALITY

* Added `from_10x_to_h5ad` and `download_10x_dataset` components.

## MINOR CHANGES
* Workflow `bd_rhapsody_wta`: Minor change to workflow to allow for easy processing of multiple samples with a tsv.

* Component `bd_rhapsody_wta`: Added more parameters, `--parallel` and `--timestamps`.

* Added `pbmc_1k_protein_v3` as a test resource.

* Translate `bd_rhapsody_extracth5ad` from R into Python script.

* `bd_rhapsody_wta`: Remove temporary directory after execution.

* `files/make_params`: Implement unit tests (PR #505).

# openpipeline 0.1.0

* Initial release containing only a `bd_rhapsody_wta` pipeline and corresponding components.
