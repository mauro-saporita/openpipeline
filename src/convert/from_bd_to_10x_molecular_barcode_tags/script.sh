#!/bin/bash

set -eo pipefail

extra_params=()

if [ "$par_bam" == "true" ]; then
  extra_params+=("--bam")
fi

cat \
    <(samtools view -SH "$par_input") \
    <(samtools view "$par_input" |  grep "MA:Z:*"  | sed  "s/MA:Z:/UB:Z:/" ) | \
samtools view -Sh "${extra_params[@]}" -@"$par_threads" - > "$par_output"
