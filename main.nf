#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/deepmodeloptim
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/nf-core/deepmodeloptim
    Website: https://nf-co.re/deepmodeloptim
    Slack  : https://nfcore.slack.com/channels/deepmodeloptim
----------------------------------------------------------------------------------------
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { DEEPMODELOPTIM          } from './workflows/deepmodeloptim'
include { PIPELINE_INITIALISATION } from './subworkflows/local/utils_nfcore_deepmodeloptim_pipeline'
include { PIPELINE_COMPLETION     } from './subworkflows/local/utils_nfcore_deepmodeloptim_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOWS FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Run main analysis pipeline depending on type of input
//
workflow NFCORE_DEEPMODELOPTIM {

    take:
        data_config
        data
        model
        model_config
        initial_weights
        genome_sizes

    main:

    //
    // WORKFLOW: Run pipeline
    //
    DEEPMODELOPTIM (
        data_config,
        data,
        model,
        model_config,
        initial_weights,
        genome_sizes
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    main:
    //
    // SUBWORKFLOW: Run initialisation tasks
    //
    PIPELINE_INITIALISATION (
        params.version,
        params.validate_params,
        params.monochrome_logs,
        args,
        params.outdir //,
        // params.input
    )

    //
    // INPUT: Load input data
    // todo: not sure if this should be here
    //
    ch_data_config     = Channel.fromPath(params.data_config, checkIfExists: true).map { it -> [[id:it.baseName], it]}
    ch_data            = Channel.fromPath(params.data, checkIfExists: true).map { it -> [[id:it.baseName], it]}
    ch_model           = Channel.fromPath(params.model, checkIfExists: true).map { it -> [[id:it.baseName], it]}
    ch_model_config    = Channel.fromPath(params.model_config, checkIfExists: true).map { it -> [[id:it.baseName], it]}
    if (params.initial_weights != null) {
        ch_initial_weights = Channel.fromPath(params.initial_weights, checkIfExists: true)
            .map { it -> [[id:it.baseName], it]}
    } else {
        ch_initial_weights = Channel.of([[],[]])
    }
    ch_genome_sizes = Channel.fromPath(params.genome_sizes, checkIfExists: true).map { it -> [[id:it.baseName], it]}

    //
    // WORKFLOW: Run main workflow
    //
    NFCORE_DEEPMODELOPTIM (
        ch_data_config,
        ch_data,
        ch_model,
        ch_model_config,
        ch_initial_weights,
        ch_genome_sizes
    )

    //
    // SUBWORKFLOW: Run completion tasks
    //
    PIPELINE_COMPLETION (
        params.email,
        params.email_on_fail,
        params.plaintext_email,
        params.outdir,
        params.monochrome_logs,
        params.hook_url
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
