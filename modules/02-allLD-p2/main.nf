/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process split_vars {

    publishDir "${params.results_dir}/02-${task.process.replaceAll(/.*:/, '')}/", mode:"symlink"

    input:
      path pvar

    output:
      path "*", emit: results_split_vars

    script:
    """
    awk '!/^#/ {print \$3}' $pvar \
    | split -l 1000 -d -a 6 - idchunk_
    """

}

process allld {

    publishDir "${params.results_dir}/02-${task.process.replaceAll(/.*:/, '')}/", mode:"symlink"

    input:
      tuple path(pgen), path(pvar), path(psam), path(chunk), path(mtx_script_channel)

    output:
      path "*", emit: results_allld

    script:
    """
    # Calculate unphased pairwise r2 text table using PLINK 1.9 stable parameters.
    # We bypass the 1Mb distance ceiling (--ld-window-kb) and drop the r2 reporting threshold to 0.
    plink2 --pfile ${pgen.simpleName}.filtered \
       --r2-unphased inter-chr yes-really \
        cols='id' \
       --ld-window-r2 ${params.ld_r2} \
       --ld-snp-list $chunk \
       --threads ${params.ld_thr} \
       --out "$chunk".temp_raw

    Rscript --vanilla $mtx_script_channel "$chunk".temp_raw.vcor \
    && rm *.temp_raw.vcor
    """

}

/* name a flow for easy import */
workflow ALLLD {

 take:
    pgen_channel
    pvar_file_channel
    psam_channel
    mtx_script_channel

 main:

    allchunks = split_vars( pvar_file_channel ) | flatten

    allmat = pgen_channel
    .combine( pvar_file_channel )
    .combine( psam_channel )
    .combine( allchunks )
    .combine( mtx_script_channel )
    // .view( )

    allld( allmat )

  emit:
    results = allld.out.results_allld

}