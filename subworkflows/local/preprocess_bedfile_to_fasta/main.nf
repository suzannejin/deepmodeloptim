include { EXTRACT_DATA_CONTENT_BY_COLUMN_VALUES as EXTRACT_FOREGROUND } from '../../../modules/local/extract_data_content_by_column_values'

workflow PREPROCESS_BEDFILE_TO_FASTA {
    take:
    ch_input
    ch_config

    main:

    // extract foreground

    ch_foreground_ids = ch_config.map{ meta ->
            [meta, meta.variable, meta.target]
        }
    
    EXTRACT_FOREGROUND(
        ch_foreground_ids,
        ch_input.collect()
    )

    // extract background

    // merge different background if needed

    // run bedtools to extend and remove overlapping peaks

    // run bedtools to convert to fasta

    // emit:
}