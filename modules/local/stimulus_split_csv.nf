
process STIMULUS_SPLIT_DATA {

    tag "${sub_config}"
    label 'process_low'
    // TODO: push image to nf-core quay.io
    container "docker.io/mathysgrapotte/stimulus-py:0.2.6"

    input:
    tuple val(meta), path(sub_config)
    tuple path(data)  // TODO: create data channel with meta2, this is nf-core style

    output:
    tuple val(meta), path("${prefix}.csv"), emit: csv_with_split

    script:
    prefix = "${data.simpleName}-split-${meta.id}"
    """
    stimulus-split-csv \
        -c ${data} \
        -y ${sub_config} \
        -o ${prefix}.csv
    """

    stub:
    prefix = "${data.simpleName}-split-${meta.id}"
    """
    touch ${prefix}.csv
    """
}
