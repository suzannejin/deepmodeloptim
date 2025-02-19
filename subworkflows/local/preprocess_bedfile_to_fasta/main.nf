/*
TODO write the meta.yaml file for this workflow

Basically, this subworkflow expects to get a bed file as input,
and a configuration channel that contains the target and background.

Then it extracts the foreground and the background from the bed file.
Alternatively, it can build the background from random regions or from
the foreground peaks.

The extracted peaks are then extended and overlapping peaks are removed.
Finally, the peaks are converted to fasta format.

In this way, by knowing the target and background peaks, we can build
the dataset for stimulus with sequences as input and foreground/background
(0|1) classification as label.

*/
include { EXTRACT_DATA_CONTENT_BY_COLUMN_VALUES as EXTRACT_FOREGROUND        } from '../../../modules/local/extract_data_content_by_column_values'
include { EXTRACT_DATA_CONTENT_BY_COLUMN_VALUES as EXTRACT_BACKGROUND_ALIENS } from '../../../modules/local/extract_data_content_by_column_values'
include { GAWK as CENTER_AROUND_PEAK                                         } from '../../../modules/nf-core/gawk'


workflow PREPROCESS_BEDFILE_TO_FASTA {
    take:
    ch_input
    ch_config

    main:

    // TODO the foolowing is just a proof of concept and how to example 
    // on the usage of the GAWK nf-core module for modifying
    // bed start and end values based on distance from peak (centering).
    /*
    ch_genome_size = channel.fromPath("/users/cn/avignoli/test/human.hg38.genome") // abs path so you can go and check if needed on cluster.
    ch_input_bed = channel.fromPath("/users/cn/avignoli/test/input.bed")
    ch_center_input = ch_genome_size.combine(ch_input_bed).map{
        it -> [["id" : it[1].getBaseName(), "size" : 10], it]
    } // TODO replace size with the appropriate params/variable containing the size to be used for centering
    ch_awk_program = channel.fromPath('./bin/center_around_peak.sh')
    CENTER_AROUND_PEAK(ch_center_input, ch_awk_program)
    */

    // extract foreground

    ch_foreground_ids = ch_config
        .map{ it ->
            [it, it.variable, it.target]
        }
    EXTRACT_FOREGROUND(
        ch_foreground_ids,
        ch_input.collect()
    )
    ch_foreground = EXTRACT_FOREGROUND.out.extracted_data

    // extract background - aliens

    ch_background_ids = ch_config
        .filter { it.background_type == 'aliens' }
        .map{ it ->
            [it, it.variable, it.background]
        }
    EXTRACT_BACKGROUND_ALIENS(
        ch_background_ids,
        ch_input.collect()
    )
    ch_background_aliens = EXTRACT_BACKGROUND_ALIENS.out.extracted_data

    ch_background_aliens.view()

    // merge different background if needed

    // run bedtools to extend and remove overlapping peaks

    // run bedtools to convert to fasta

    // emit:
}