
/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process select_snps {

    publishDir "${params.results_dir}/03-${task.process.replaceAll(/.*:/, '')}/", mode:"symlink"

    input:
      path alltsv_channel
      path selectsnp_script_channel

    output:
      path "*", emit: results_select_snps

    script:
    """
    zgrep -e ${params.snp1} -e ${params.snp2} $alltsv_channel > tmp.tsv
    Rscript --vanilla $selectsnp_script_channel tmp.tsv ${params.snp1} ${params.snp2}
    rm tmp.tsv
    """

}

/* name a flow for easy import */
workflow SELECT_SNPS {

 take:
    alltsv_channel
    selectsnp_script_channel

 main:

    select_snps( alltsv_channel, selectsnp_script_channel )

  emit:
    results = select_snps.out.results_select_snps

}