
#!/bin/bash

## VIASH START
# The following code has been auto-generated by Viash.
par_input='resources_test/10x_5k_anticmv/processed/10x_5k_anticmv.cellranger_multi.output.output/multi/count/raw_feature_bc_matrix.h5'
par_output='output.h5mu'
par_total_droplets_included='50000'
par_epochs='150'
par_fpr='0.01'
par_exclude_antibody_capture='false'
par_learning_rate='0.001'
## VIASH END


extra_params=( )

[ ! -z $par_model ] && extra_params+=( "--model" "$par_model" )
[ ! -z $par_total_droplets_included ] && extra_params+=( "--total-droplets-included" "$par_total_droplets_included" )
[ ! -z $par_epochs ] && extra_params+=( "--epochs" "$par_epochs" )
[ ! -z $par_fdr ] && extra_params+=( "--fdr" "$par_fdr" )
[ $par_exclude_antibody_capture == "true" ] && extra_params+=( "--exclude-antibody-capture" )
[ ! -z $par_learning_rate ] && extra_params+=( "--learning-rate" "$par_learning_rate" )
[ $par_cuda == "true" ] && extra_params+=( "--cuda" )

cellbender \
  remove-background \
  --input "$par_input" \
  --output "$par_output" \
  "${extra_params[@]}"

[ ! -z "$par_output_report" ] && mv "${par_output%.h5}.pdf" "$par_output_report"
[ ! -z "$par_output_cell_barcodes" ] && mv "${par_output%.h5}_cell_barcodes.csv" "$par_output_cell_barcodes"
[ ! -z "$par_output_filtered" ] && mv "${par_output%.h5}_filtered.h5" "$par_output_filtered"