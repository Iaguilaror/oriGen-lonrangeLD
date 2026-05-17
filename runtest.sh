#!/bin/bash

input_vcf="test/data/chr22_random10000.vcf.gz"
output_directory="test/results"
res_config="configfiles/low-res-machine.config"

echo -e "======\n Testing NF execution \n======" \
&& rm -rf $output_directory \
&& nextflow run main.nf \
    --input_vcf "$input_vcf" \
    --maf "0.05" \
    --geno "0.02" \
    --ld_thr "32" \
	--output_dir $output_directory \
	-c $res_config \
	-resume \
	-with-report $output_directory/`date +%Y%m%d_%H%M%S`_report.html \
	-with-dag $output_directory/`date +%Y%m%d_%H%M%S`.DAG.html \
&& echo -e "======\n Basic pipeline TEST SUCCESSFUL \n======"