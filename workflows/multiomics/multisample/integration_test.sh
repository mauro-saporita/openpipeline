#!/bin/bash



# get the root of the directory
REPO_ROOT=$(git rev-parse --show-toplevel)

# ensure that the command below is run from the root of the repository
cd "$REPO_ROOT"

export NXF_VER=23.04.2

nextflow \
  run . \
  -main-script workflows/multiomics/multisample/main.nf \
  -entry test_wf \
  -profile docker,no_publish \
  -c workflows/utils/labels_ci.config


nextflow \
  run . \
  -main-script workflows/multiomics/multisample/main.nf \
  -entry test_wf2 \
  -profile docker,no_publish \
  -c workflows/utils/labels_ci.config
