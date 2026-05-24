/* Inititate DSL2 */
nextflow.enable.dsl=2

process gathermtx {

    publishDir "${params.results_dir}/02.5-${task.process.replaceAll(/.*:/, '')}/", mode:"symlink"

    input:
      path rds
      path script

    output:
      path "*", emit: results_gathermtx

    script:
    """
    Rscript --vanilla $script
    """

}

/* name a flow for easy import */
workflow GATHERMTX {

 take:
    rds_channel
    gather_script_channel

 main:

    gathermtx( rds_channel, gather_script_channel )

  emit:
    results = gathermtx.out.results_gathermtx

}