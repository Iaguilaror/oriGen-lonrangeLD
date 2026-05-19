#!/bin/bash

# $1 = temp_raw.ld 
# $2 = ${bed.simpleName}_clean_matrix.ld.tsv.gz
# $3 = ${params.ld_thr}

ifile="$1"
ofile="$2"
nthreads="$3"

zcat $ifile \
| awk -v OFS="\t" 'BEGIN {print "A", "B", "r2"} 
                 NR > 1 {printf "%s\t%s\t%.2f\n", $3, $6, $7}' \
| bgzip --threads $nthreads \
> $ofile

