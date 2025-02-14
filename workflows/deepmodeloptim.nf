/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_deepmodeloptim_pipeline'
include { CHECK_MODEL_WF         } from '../subworkflows/local/check_model'
include { SPLIT_DATA_CONFIG_WF   } from '../subworkflows/local/split_data_config'
include { SPLIT_CSV_WF           } from '../subworkflows/local/split_csv'
include { TRANSFORM_CSV_WF       } from '../subworkflows/local/transform_csv'
include { TUNE_WF                } from '../subworkflows/local/tune'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow DEEPMODELOPTIM {

    take:
    // Updated input channels for stimulus-py
    ch_data_config
    ch_data
    ch_model
    ch_model_config
    //ch_initial_weights

    main:

    ch_versions = Channel.empty()

    // ==============================================================================
    // split meta yaml config file into individual yaml files
    // ==============================================================================

    SPLIT_DATA_CONFIG_WF( ch_data_config )
    ch_yaml_sub_config = SPLIT_DATA_CONFIG_WF.out.sub_config

    // ==============================================================================
    // split csv data file
    // ==============================================================================

    // NOTE for the moment, the previous step of yaml split is splitting the yaml file
    // into individual sub yaml files with all the fields.
    // The best would be to have a first step that splits into individual splitting-related
    // configs into individual splitting yaml files, and then a second step that splits the
    // transformation-related configs into individual transformation yaml files.
    // Then this pipeline will run m split configs x n transform configs times.
    // 
    // Given this is not possible now, this implementation will only allow the user to
    // provide a yaml file that only contains one splitting way. 
    // Here we take the first sub yaml for data splitting, since all sub configs contain
    // the same information about data splitting.
    //
    // TODO remove this when the above is implemented

    SPLIT_CSV_WF(
        ch_data,
        ch_yaml_sub_config.first()
    )
    ch_split_data_with_sub_config = SPLIT_CSV_WF.out.split_data
        .combine(ch_yaml_sub_config)
        .multiMap { meta_data, data, meta_yaml, yaml ->
            data:
                [meta_yaml, data]
            yaml:
                [meta_yaml, yaml]
        }

    // ==============================================================================
    // transform csv file
    // ==============================================================================

    TRANSFORM_CSV_WF(
        ch_split_data_with_sub_config.data,
        ch_split_data_with_sub_config.yaml
    )
    ch_transformed_data = TRANSFORM_CSV_WF.out.transformed_data
    
    // ch_sub_configs = ch_transformed_data.map { _csv, yaml -> yaml }
    // ch_transformed_data_splits = ch_transformed_data.map { csv, _yaml -> csv }

    // ch_first_sub_config = ch_sub_configs.first()
    // ch_first_transformed_data_split = ch_transformed_data_splits.first()

    
    // /*
    // // Update CHECK_MODEL invocation using channels
    // CHECK_MODEL_WF (
    //      ch_first_sub_config,
    //      ch_first_data_split,
    //      ch_model,
    //      ch_model_config
    //      //ch_initial_weights
    // )
    // */

    
    // TUNE_WF(
    //     ch_transformed_data_splits,
    //     ch_sub_configs,
    //     ch_model,
    //     ch_model_config
    // )

    
    // TUNE_WF.out.tune_specs.view()

    // emit: 
    // ch_split_data
    /*
    prepared_data = HANDLE_DATA.out.data
    //HANDLE_DATA.out.data.view()

    // Update HANDLE_TUNE invocation using channels
    HANDLE_TUNE(
        ch_model,
        ch_model_config,
        prepared_data,
        ch_initial_weights
    )
    //HANDLE_TUNE.out.model.view()
    //HANDLE_TUNE.out.tune_out.view()

    /*
    // Software versions collation remains as comments
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_'  + 'pipeline_software_' +  ''  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }
    

    emit:
    versions = ch_versions  // channel: [ path(versions.yml) ]
    */

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
