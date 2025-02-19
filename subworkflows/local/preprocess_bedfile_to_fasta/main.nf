/**
 * Preprocess BED File to FASTA Workflow
 *
 * This subworkflow is designed to process a BED file and convert it into FASTA format,
 * preparing datasets for downstream sequence-based classification tasks.
 *
 * Workflow Steps:
 *   1. Center peaks and trim them to a fixed size.
 *   2. Extract foreground (target).
 *   3. Extract background (aliens, shades, random).
 *   4. Convert the processed peaks into FASTA format.
 *
 * Expected Inputs:
 *   - A channel containing BED file with peak regions.
 *   - A configuration channel providing the necessary details for extracting target 
 *     (foreground) and background.
 *
 * Output:
 *   - A FASTA formatted file containing sequences for both the target (foreground) and
 *     the corresponding background regions.
 *
 * Note:
 *   - A meta.yaml file describing the workflow configuration, metadata, and dependencies
 *     should be created as part of the workflow documentation.
 */

include { GAWK as CENTER_AROUND_PEAK                                         } from '../../../modules/nf-core/gawk'
include { EXTRACT_DATA_CONTENT_BY_COLUMN_VALUES as EXTRACT_FOREGROUND        } from '../../../modules/local/extract_data_content_by_column_values'
include { EXTRACT_DATA_CONTENT_BY_COLUMN_VALUES as EXTRACT_BACKGROUND_ALIENS } from '../../../modules/local/extract_data_content_by_column_values'
include { BEDTOOLS_SUBTRACT                                                  } from '../../../modules/nf-core/bedtools/subtract'
include { BEDTOOLS_GETFASTA as BEDTOOLS_GETFASTA_FOREGROUND                  } from '../../../modules/nf-core/bedtools/getfasta'
include { BEDTOOLS_GETFASTA as BEDTOOLS_GETFASTA_BACKGROUND                  } from '../../../modules/nf-core/bedtools/getfasta'


workflow PREPROCESS_BEDFILE_TO_FASTA {
    take:
    ch_input
    ch_config
    ch_genome
    ch_genome_sizes

    main:

    // TODO: it would be nice to check that the input file is actually a bed file

    // ==============================================================================
    // align peaks
    // ==============================================================================

    // use the GAWK nf-core module for modifying bed start and end values 
    // based on distance from peak (centering).

    ch_input_for_centering = ch_input
        .combine(ch_genome_sizes.map{it[1]})
        .map { meta, input, genome_sizes ->
            [meta, [genome_sizes, input]]
        }
    ch_awk_program = Channel.fromPath('./bin/center_around_peak.sh')

    CENTER_AROUND_PEAK(
        ch_input_for_centering, 
        ch_awk_program
    )
    ch_input = CENTER_AROUND_PEAK.out.output

    // ==============================================================================
    // extract foreground
    // ==============================================================================

    ch_foreground_ids = ch_config
        .map{ it ->
            [it, it.variable, it.target]
        }
    EXTRACT_FOREGROUND(
        ch_foreground_ids,
        ch_input.collect()
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
        ch_input.collect()
    )
    ch_background_aliens = EXTRACT_BACKGROUND_ALIENS.out.extracted_data

    // extract background - shades

    // extract background - random 

    // merge different background if needed
    // TODO: implement this
    // for the moment use aliens background
    
    ch_background = ch_background_aliens

    // run bedtools to remove overlapping peaks
    // this creates a clean background with no overlapping peaks with the foreground

    BEDTOOLS_SUBTRACT(
        ch_background.join(ch_foreground)
    )
    ch_background = BEDTOOLS_SUBTRACT.out.bed

    // ==============================================================================
    // extract fasta sequences
    // ==============================================================================

    // run bedtools to convert to fasta

    BEDTOOLS_GETFASTA_FOREGROUND(
        ch_foreground,
        ch_genome.map{it[1]}
    )

    BEDTOOLS_GETFASTA_BACKGROUND(
        ch_background,
        ch_genome.map{it[1]}
    )

    emit:
    foreground = BEDTOOLS_GETFASTA_FOREGROUND.out.fasta
    background = BEDTOOLS_GETFASTA_BACKGROUND.out.fasta
}