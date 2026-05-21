
/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process allld {

    publishDir "${params.results_dir}/02-${task.process.replaceAll(/.*:/, '')}/", mode:"symlink"

    input:
      path pgen
      path pvar
      path psam

    output:
      path "*", emit: results_allld

    script:
    """
    # Calculate unphased pairwise r2 text table using PLINK 1.9 stable parameters.
    # We bypass the 1Mb distance ceiling (--ld-window-kb) and drop the r2 reporting threshold to 0.
    plink2 --pfile ${pgen.simpleName}.filtered \
       --r2-unphased inter-chr yes-really zs \
        cols='id' \
       --ld-window-r2 ${params.ld_r2} \
       --threads ${params.ld_thr} \
       --out temp_raw

    """

}

/* name a flow for easy import */
workflow ALLLD {

 take:
    pgen_channel
    pvar_file_channel
    psam_channel

 main:

    allld( pgen_channel, pvar_file_channel, psam_channel )

  emit:
    results = allld.out.results_allld

}