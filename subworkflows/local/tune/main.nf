/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { STIMULUS_TUNE } from '../../../modules/local/stimulus_tune.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN SUBWORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow TUNE_WF {
    take:
    ch_transformed_data
    ch_sub_configs
    ch_model
    ch_model_config
    
    main:
    // Map channels to include a key based on index number only
    ch_data_keyed = ch_transformed_data.map { file -> 
        def key = (file.name =~ /(\d+)/)[0][1]  // Extract first number found
        [key, file] 
    }
    ch_config_keyed = ch_sub_configs.map { file -> 
        def key = (file.name =~ /(\d+)/)[0][1]  // Extract first number found
        [key, file] 
    }

    // Join by key then add single elements
    ch_input = ch_data_keyed.join(ch_config_keyed)
        .map { _key, data, config -> [data, config] }  // Remove key
        .combine(ch_model)
        .combine(ch_model_config)

    STIMULUS_TUNE(ch_input)

    emit:
    tune_specs = STIMULUS_TUNE.out.tune_specs
}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
