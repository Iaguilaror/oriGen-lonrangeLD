
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
    """s
    # Stream VCF directly into a filtered PLINK 1.9 binary structure (BED/BIM/FAM)
    plink --vcf ${vcf} \
          --maf ${params.maf} \
          --geno ${params.geno} \
          --make-bed \
          --out ${vcf.simpleName}.filtered

    # 2. Use awk to replace missing IDs with an incrementing number
    awk -vOFS="\t" '{ \$2 = NR } {print}' \
    ${vcf.simpleName}.filtered.bim > ${vcf.simpleName}.filtered.bim.tmp

    mv ${vcf.simpleName}.filtered.bim.tmp ${vcf.simpleName}.filtered.bim
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