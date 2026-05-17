#!/usr/bin/env bash
## This small script runs a module test with the sample data

# remove previous tests
rm -rf .nextflow.log* work

# remove previous results
rm -rf test/results

# create a results dir
mkdir -p test/results

# run nf script
nextflow run testmodule.nf \
    --input_vcf "test/data/chr22_random10000.vcf.gz" \
    --maf "0.05" \
    --geno "0.02" \
&& echo "[>>>] Module Test Successful"