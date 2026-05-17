
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
    # Stream VCF directly into a filtered PLINK 1.9 binary structure (BED/BIM/FAM)
    plink --vcf ${vcf} \
          --maf ${params.maf} \
          --geno ${params.geno} \
          --set-missing-var-ids @_\\#_\\\$1_\\\$2 \
          --make-bed \
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