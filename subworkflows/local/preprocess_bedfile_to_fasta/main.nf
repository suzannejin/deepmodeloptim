include { EXTRACT_DATA_CONTENT_BY_COLUMN_VALUES as EXTRACT_FOREGROUND } from '../../../modules/local/extract_data_content_by_column_values'

workflow PREPROCESS_BEDFILE_TO_FASTA {
    take:
    ch_input

    main:

    // TODO at the beginning of the pipeline, parse the preprocessing data that specify the foreground and background
    // here this is only temporary for testing purpose
    ch_foreground_ids = Channel.of([[id:'ZNF367'],'tf_name','ZNF367'])
    ch_foreground_ids.view()

    // extract foreground
    EXTRACT_FOREGROUND(
        ch_foreground_ids,
        ch_input
    )

    // extract background

    // merge different background if needed

    // run bedtools to extend and remove overlapping peaks

    // run bedtools to convert to fasta

    // emit:
}