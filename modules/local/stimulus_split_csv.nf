
process STIMULUS_SPLIT_DATA {

    tag "${data_sub_config}"
    label 'process_low'
    // TODO: push image to nf-core quay.io
    container "docker.io/mathysgrapotte/stimulus-py:0.2.4.dev"

    input:
    tuple path(data), path(data_sub_config)

    output:
    tuple path(output), path(data_sub_config), emit: csv_with_split

    script:
    yaml_index = data_sub_config.simpleName
    output = "${data.simpleName}-split-${yaml_index}.csv"
    """
    stimulus-split-csv -c ${data} -y ${data_sub_config} -o ${output}
    """

    stub:
    output = "${data.simpleName}-split.csv"
    """
    touch ${output}
    """
}
