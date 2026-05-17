/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { ALLLD_QC }    from './main.nf'

/* declare input channel for testing */
    Channel
        .fromPath( "test/data/*.tsv.gz" )
        .set { alltsv_channel }

/* declare scripts channel for testing */
allqc_script_channel = Channel.fromPath( "scripts/02.5-explore.R" )

workflow {
  ALLLD_QC( alltsv_channel, allqc_script_channel )
}