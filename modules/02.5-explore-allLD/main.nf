
/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process allld_qc {

    publishDir "${params.results_dir}/02.5-${task.process.replaceAll(/.*:/, '')}/", mode:"symlink"

    input:
      path alltsv_channel
      path allqc_script_channel

    output:
      path "*", emit: results_allld_qc

    script:
    """
    Rscript --vanilla $allqc_script_channel $alltsv_channel
    """

}

/* name a flow for easy import */
workflow ALLLD_QC {

 take:
    alltsv_channel
    allqc_script_channel

 main:

    allld_qc( alltsv_channel, allqc_script_channel )

  emit:
    results = allld_qc.out.results_allld_qc

}