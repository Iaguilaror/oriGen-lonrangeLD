
/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process allld {

    publishDir "${params.results_dir}/02-${task.process.replaceAll(/.*:/, '')}/", mode:"symlink"

    input:
      path bed
      path bim
      path fam

    output:
      path "*", emit: results_allld

    script:
    """
    # Calculate unphased pairwise r2 text table using PLINK 1.9 stable parameters.
    # We bypass the 1Mb distance ceiling (--ld-window-kb) and drop the r2 reporting threshold to 0.
    plink --bed ${bed} \
          --bim ${bim} \
          --fam ${fam} \
          --r2 \
          --ld-window 999999999 \
          --ld-window-kb 999999999 \
          --ld-window-r2 ${params.ld_r2} \
          --threads ${params.ld_thr} \
          --out temp_raw

    # 2. Extract only columns 3 (SNP_A), 6 (SNP_B), and 7 (R2)
    export LC_ALL=C
    cat temp_raw.ld \
    | tr -s " " \
    | cut -d" " -f4,7,8 \
    > ${bed.simpleName}_clean_matrix.ld.tsv

    # 3. Clean up the temporary heavy files instantly to save disk space
    rm -f temp_raw.ld temp_raw.nosex

    # compress
    bgzip --threads ${params.ld_thr} ${bed.simpleName}_clean_matrix.ld.tsv
    """

}

/* name a flow for easy import */
workflow ALLLD {

 take:
    bed_channel
    bim_file_channel
    fam_channel

 main:

    allld( bed_channel, bim_file_channel, fam_channel )

  emit:
    results = allld.out.results_allld

}