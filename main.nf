#!/usr/bin/env nextflow

/*================================================================
The Treviño LAB presents...
  LongRangeLD
- A tool for calculating long range LD in oriGen

- This pipeline is meant to reproduce the results in: TO-DO-add url and doi after paper is published

==================================================================
Version: 0.0.1

==================================================================
Authors:
- Bioinformatics Design
 Israel Aguilar-Ordonez (iaguilaror@gmail.com)
 Victor Treviño-Alvarado (vtrevino@tec.mx)

- Bioinformatics Development
 Israel Aguilar-Ordonez (iaguilaror@gmail.com)

=============================
Pipeline Processes In Brief:

Pre-processing:

Core-processing:

Pos-processing

Anlysis


ENDING

================================================================*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PREPARE PARAMS DOCUMENTATION AND FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*//////////////////////////////
  Define pipeline version
  If you bump the number, remember to bump it in the header description at the begining of this script too
*/
params.ver = "0.0.1"

/*//////////////////////////////
  Define pipeline Name
  This will be used as a name to include in the results and intermediates directory names
*/
params.pipeline_name = "origen-lonrangeLD"

/*//////////////////////////////
  Define the Nextflow version under which this pipeline was developed or successfuly tested
  Updated by iaguilar at SEP 2024
*/
params.nextflow_required_version = '24.04.3'

/*
  Initiate default values for parameters
  to avoid "WARN: Access to undefined parameter" messages
*/
params.help     = false   //default is false to not trigger help message automatically at every run
params.version  = false   //default is false to not trigger version message automatically at every run

params.input_vcf     =	false	//if no inputh path is provided, value is false to provoke the error during the parameter validation block

params.maf  = false
params.geno  = false
params.plink  = false
params.ld_thr  = false


// /* load functions for testing env */
include { get_fullParent }  from './modules/useful_functions.nf'

/*

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     INPUT PARAMETER VALIDATION BLOCK
  TODO (iaguilar) check the extension of input queries; see getExtension() at https://www.nextflow.io/docs/latest/script.html#check-file-attributes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
Output directory definition
Default value to create directory is the parent dir of --input_dir
*/
params.output_dir = get_fullParent( params.input_vcf )

/*
  Results and Intermediate directory definition
  They are always relative to the base Output Directory
  and they always include the pipeline name in the variable (pipeline_name) defined by this Script
  This directories will be automatically created by the pipeline to store files during the run
*/

params.results_dir       =  "${params.output_dir}/${params.pipeline_name}-results/"
params.intermediates_dir =  "${params.output_dir}/${params.pipeline_name}-intermediate/"

/*

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/* load workflows */

include { VCF2PLINK }     from  './modules/01-filter-plink1'
include { ALLLD }         from  './modules/02-allLD'
include { ALLLD_QC }      from  './modules/02.5-explore-allLD'
include { SELECT_SNPS }   from  './modules/03-select-snps'


/* load scripts to send to workdirs */
/* declare scripts channel from modules */
allqc_script_channel = Channel.fromPath( "scripts/02.5-explore.R" )
selectsnp_script_channel = Channel.fromPath( "scripts/03-select.R" )

workflow mainflow {

  main:

// Manually pair the BAM files with their index files
    Channel
        .fromPath( "${params.input_vcf}" )
        .set { vcf_channel }
    
    all_plink = VCF2PLINK( vcf_channel ) | flatten

/* declare input channel for testing */
    Channel
        .fromPath( "test/data/*.bed" )

    all_plink
		  .filter { file(it).name.endsWith('.bed') }
      .set { bed_channel }

/* declare input channel for testing */
    all_plink
		  .filter { file(it).name.endsWith('.bim') }
      .set { bim_file_channel }

/* declare input channel for testing */
    all_plink
		  .filter { file(it).name.endsWith('.fam') }
      .set { fam_channel }

    all_ld = ALLLD( bed_channel, bim_file_channel, fam_channel ) | flatten

    all_ld
      .filter { file(it).name.endsWith('.tsv.gz') }
      .set { alltsv_channel }

    ALLLD_QC( alltsv_channel, allqc_script_channel )

    SELECT_SNPS( alltsv_channel, selectsnp_script_channel )

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
// See: https://github.com/nf-core/rnaseq/issues/619
//
workflow {

    mainflow( )

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/