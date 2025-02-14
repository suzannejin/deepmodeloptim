/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { STIMULUS_SPLIT_DATA } from '../../../modules/local/stimulus_split_csv.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN SUBWORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow SPLIT_CSV_WF {

    take:
        ch_data
        ch_yaml_sub_config

    main:

        // ==============================================================================
        // Split csv data using stimulus
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
        // TODO remove this when the above is implemented.

        STIMULUS_SPLIT_DATA(
            ch_yaml_sub_config.first(),
            ch_data
        )
        ch_split_data = STIMULUS_SPLIT_DATA.out.csv_with_split
            .combine(ch_yaml_sub_config)
            .map { meta_csv, csv, meta_yaml, yaml ->
                [meta_yaml, csv, yaml]
            }

    emit:
        split_data = ch_split_data
}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
