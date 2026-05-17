
/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process vcf2plink {

    publishDir "${params.results_dir}/01-${task.process.replaceAll(/.*:/, '')}/", mode:"symlink"

    input:
      path vcf

    output:
        path "*", emit: results_vcf2plink

    script:
    """
    # Stream VCF directly into a filtered PLINK2 binary structure in a single highly optimized step
    plink2 --vcf ${vcf} \
           --maf ${params.maf} \
           --geno ${params.geno} \
           --set-all-var-ids '@_#_\$r_\$a' \
           --make-pgen \
           --threads ${params.plink_thr} \
           --out ${vcf.simpleName}.filtered
    """

}

/* name a flow for easy import */
workflow VCF2PLINK {

 take:
    vcf_channel

 main:

    vcf_channel | vcf2plink 

  emit:
    vcf2plink.out[0]

}