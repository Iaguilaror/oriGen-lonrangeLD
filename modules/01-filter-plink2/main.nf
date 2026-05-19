
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
           --make-pgen \
           --threads ${params.plink_thr} \
           --out ${vcf.simpleName}.filtered

    # 2. Use awk to replace missing IDs with an incrementing number
    awk -v OFS="\t" '/^#/ {print; next} {\$3 = NR; \$6 = "."; print}' \
    ${vcf.simpleName}.filtered.pvar > ${vcf.simpleName}.filtered.pvar.tmp

    mv ${vcf.simpleName}.filtered.pvar.tmp ${vcf.simpleName}.filtered.pvar
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