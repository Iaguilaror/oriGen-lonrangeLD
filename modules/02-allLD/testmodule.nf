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
        .fromPath( "test/data/*.bed" )
        .set { bed_channel }

/* declare input channel for testing */
    Channel
        .fromPath( "test/data/*.bim" )
        .set { bim_file_channel }

/* declare input channel for testing */
    Channel
        .fromPath( "test/data/*.fam" )
        .set { fam_channel }

/* declare scripts channel for testing */
// NONE

workflow {
  ALLLD( bed_channel, bim_file_channel, fam_channel )
//   ALLLD( bed_channel, bim_file_channel, fam_channel )
}