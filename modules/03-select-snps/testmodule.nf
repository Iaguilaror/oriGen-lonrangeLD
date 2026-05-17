/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { SELECT_SNPS }    from './main.nf'

/* declare input channel for testing */
    Channel
        .fromPath( "test/data/*.tsv.gz" )
        .set { alltsv_channel }

/* declare scripts channel for testing */
selectsnp_script_channel = Channel.fromPath( "scripts/03-select.R" )

workflow {
  SELECT_SNPS( alltsv_channel, selectsnp_script_channel )
}