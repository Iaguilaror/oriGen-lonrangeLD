/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { ALLLD }    from './main.nf'

/* declare input channel for testing */
    Channel
        .fromPath( "test/data/*.pgen" )
        .set {pgen_channel }

/* declare input channel for testing */
    Channel
        .fromPath( "test/data/*.pvar" )
        .set { pvar_file_channel }

/* declare input channel for testing */
    Channel
        .fromPath( "test/data/*.psam" )
        .set { psam_channel }

/* declare scripts channel for testing */
// awk_script_channel = Channel.fromPath( "scripts/02.awk-filter.sh" )

workflow {
  ALLLD( pgen_channel, pvar_file_channel, psam_channel )
}