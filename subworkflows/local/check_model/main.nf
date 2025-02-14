// Start of Selection
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// Updated import to reference the new module path as per the latest codebase conventions 
include { CHECK_MODEL } from '../../../modules/local/check_model.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN SUBWORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow CHECK_MODEL_WF {

    take:
        // Renamed inputs to match the keys defined in nextflow_schema.json and used in @deepmodeloptim.nf and @main.nf
        ch_data_config
        ch_data
        ch_model
        ch_model_config
        //ch_initial_weights

    main:
        def completion_message = "\n###\nThe model check was skipped.\n###\n"

        // Only perform the model check if enabled (default: true)


        // Assign incoming channels using descriptive names from the updated schema:
        data_csv     = ch_data
        model_file   = ch_model // Assumes a single model file is provided
        data_config  = ch_data_config
        model_config = ch_model_config

        // Combine channels into a single tuple in the order expected:
        // [data_csv, model_file, data_config, model_config]
        model_tuple = data_csv.combine( model_file )
                                    .combine( data_config )
                                    .combine( model_config )
                                    .map { tuple -> tuple.flatten() }

        // Append initial weights to the tuple if provided; otherwise, insert an empty list.
        //if ( !ch_initial_weights ) {
        //    model_tuple = model_tuple.map { items -> [ items[0], items[1], items[2], items[3], [] ] }
        //} else {
        //    model_tuple = model_tuple.combine( ch_initial_weights )
        //}

        // Launch the model-check process using the updated @check_model.nf implementation.
        CHECK_MODEL( model_tuple )
        completion_message = CHECK_MODEL.out.standardout

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
// End of Selection

