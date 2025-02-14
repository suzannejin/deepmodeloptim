/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { STIMULUS_TRANSFORM_CSV } from '../../../modules/local/stimulus_transform_csv.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN SUBWORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow TRANSFORM_CSV_WF {

    take:
    ch_splitted_data
    ch_sub_config


    main:
    // TODO add strategy for handling the launch of stimulus noiser as well as NF-core and other modules
    // TODO if the option is parellalization (for the above) then add csv column splitting  noising  merging

    // ==============================================================================
    // Transform data using stimulus
    // ==============================================================================

    STIMULUS_TRANSFORM_CSV(
        ch_sub_config,
        ch_splitted_data
    )
    ch_transformed_data = STIMULUS_TRANSFORM_CSV.out.transformed_data

    emit:
    transformed_data = ch_transformed_data
}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
