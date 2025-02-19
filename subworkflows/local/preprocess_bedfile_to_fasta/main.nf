/*
TODO write the meta.yaml file for this workflow

Basically, this subworkflow expects to get a bed file as input,
and a configuration channel that contains the target and background.
It also needs the genome sizes.

Then it extracts the foreground and the background from the bed file.
Alternatively, it can build the background from random regions or from
the foreground peaks.

The extracted peaks are then extended and overlapping peaks are removed.
This creates a clean background with no overlapping peaks with the foreground.
Finally, the peaks are converted to fasta format.

In this way, by knowing the target and background peaks, we can build
the dataset for stimulus with sequences as input and foreground/background
(0|1) classification as label.

*/
include { EXTRACT_DATA_CONTENT_BY_COLUMN_VALUES as EXTRACT_FOREGROUND        } from '../../../modules/local/extract_data_content_by_column_values'
include { EXTRACT_DATA_CONTENT_BY_COLUMN_VALUES as EXTRACT_BACKGROUND_ALIENS } from '../../../modules/local/extract_data_content_by_column_values'
include { BEDTOOLS_SLOP                                                      } from '../../../modules/nf-core/bedtools/slop'
include { BEDTOOLS_SUBTRACT                                                  } from '../../../modules/nf-core/bedtools/subtract'

workflow PREPROCESS_BEDFILE_TO_FASTA {
    take:
    ch_bedfile
    ch_config
    ch_genome_sizes

    main:

    // TODO: it would be nice to check that the input file is actually a bed file

    // ==============================================================================
    // extract foreground
    // ==============================================================================

    ch_foreground_ids = ch_config
        .map{ it ->
            [it, it.variable, it.target]
        }
    EXTRACT_FOREGROUND(
        ch_foreground_ids,
        ch_bedfile.collect()
    )
    ch_foreground = EXTRACT_FOREGROUND.out.extracted_data

    // ==============================================================================
    // extract background
    // ==============================================================================

    // extract background - aliens

    ch_background_ids = ch_config
        .filter { it.background_type == 'aliens' }
        .map{ it ->
            [it, it.variable, it.background]
        }
    EXTRACT_BACKGROUND_ALIENS(
        ch_background_ids,
        ch_bedfile.collect()
    )
    ch_background_aliens = EXTRACT_BACKGROUND_ALIENS.out.extracted_data

    // extract background - random

    // extract background - shades

    // merge different background if needed
    // TODO: do this when other methods are implemented. for the moment use aliens

    ch_background = ch_background_aliens

    // run bedtools to extend and remove overlapping peaks
    // this creates a clean background with no overlapping peaks with the foreground

    BEDTOOLS_SLOP(
        ch_foreground,
        ch_genome_sizes.map{ it[1] }
    )

    BEDTOOLS_SUBTRACT(
        ch_background.combine(
            BEDTOOLS_SLOP.out.bed.map{ it[1] }
        )
    )

    ch_background = BEDTOOLS_SUBTRACT.out.bed

    // ==============================================================================
    // extract fasta sequences
    // ==============================================================================



    // emit:
}