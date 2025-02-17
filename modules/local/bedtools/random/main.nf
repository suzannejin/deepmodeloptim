process BEDTOOLS_RANDOM_SAMPLING {
    label 'process_single'
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bedtools:2.31.1--h13024bc_3':
        'biocontainers/bedtools:2.31.1--h13024bc_3' }"

    input:
    tuple path(genome_file), val(number_sequences), val(length_sequences)

    output:
    path "${prefix}.bed", emit: random_background
    path "versions.yml" , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: 'random_background'
    """
    bedtools random \\
        -l $length_sequences \\
        -n $number_sequences \\
        -g $genome_file \\
        $args \\
        > ${prefix}.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bedtools: \$(bedtools --version |& sed '1!d ; s/bedtools v//')
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: 'random_background'
    """
    touch ${prefix}.bed

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bedtools: \$(bedtools --version |& sed '1!d ; s/bedtools v//')
    END_VERSIONS
    """
}
