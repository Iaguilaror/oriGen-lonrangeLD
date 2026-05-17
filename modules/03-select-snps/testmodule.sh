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
    --snp1 21_5231730_C_G \
    --snp2 22_50773552_A_G \
&& echo "[>>>] Module Test Successful"
