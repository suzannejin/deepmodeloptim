process AWK_SHADE {
    label 'process_low'
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bedtools:2.31.1--h13024bc_3':
        'biocontainers/bedtools:2.31.1--h13024bc_3' }"
    // bedtools is not actually needed here, we only use awk

    input:
    tuple path(bed), val(length), val(gap)
    path genome_index

    output:
    path "${prefix}.bed", emit: shade_background
    //path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: 'shade'
    """
    # First create an associative array with chromosome sizes
    awk '{
        chrom_sizes[\$1]=\$2
    }' ${genome_index} > chrom_sizes.txt

    awk -v w=${length} -v s=${gap} '
    # First load chromosome sizes
    FILENAME == "chrom_sizes.txt" {
        sizes[\$1]=\$2
        next
    }
    # Then process BED file
    FILENAME != "chrom_sizes.txt" && NR>1 {
        # Keep all original columns
        for(i=4;i<=NF;i++) extra=extra"\t"\$i
        
        # Only print if chromosome exists in index
        if (\$1 in sizes) {
            # Create upstream window if it stays within bounds
            if (\$2-s-w >= 0) {
                print \$1, \$2-s-w, \$2-s extra
            }
            # Create downstream window if it stays within bounds
            if (\$3+s+w <= sizes[\$1]) {
                print \$1, \$3+s, \$3+s+w extra
            }
        }
        extra=""
    }' OFS='\\t' chrom_sizes.txt ${bed} > ${prefix}.bed

    """

    stub:
    prefix = task.ext.prefix ?: 'shade'
    """
    touch ${prefix}.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bedtools: \$(bedtools --version |& sed '1!d ; s/bedtools v//')
    END_VERSIONS
    """
}

workflow {
    // Create separate channels
    bed_ch = Channel.fromPath(params.b)
    genome_ch = Channel.fromPath(params.i)
    length_ch = Channel.of(params.l)
    gap_ch = Channel.of(params.g)
    
    // Create proper input tuple (bed, length, gap)
    input_tup = bed_ch
        .combine(length_ch)
        .combine(gap_ch)
    
    // Pass tuple and genome index separately
    AWK_SHADE(input_tup, genome_ch)
}
