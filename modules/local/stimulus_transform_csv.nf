
process STIMULUS_TRANSFORM_CSV {

    tag "${data} - ${config}"
    label 'process_medium'
    // TODO: push image to nf-core quay.io
    container "docker.io/mathysgrapotte/stimulus-py:0.2.6"

    input:
    tuple val(meta), path(data), path(config)

    output:
    tuple val(meta), path("${prefix}.csv"), emit: transformed_data

    script:
    prefix = "${data.simpleName}-${meta.id}-trans"
    """
    stimulus-transform-csv \
        -c ${data} \
        -y ${config} \
        -o ${prefix}.csv
    """

    stub:
    prefix = "${data.simpleName}-${meta.id}-trans"
    """
    touch ${prefix}.csv
    """
}
