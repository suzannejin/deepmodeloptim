
process STIMULUS_TRANSFORM_CSV {

    tag "${splitted_csv} - ${sub_data_config}"
    label 'process_medium'
    // TODO: push image to nf-core quay.io
    container "docker.io/mathysgrapotte/stimulus-py:0.2.6"

    input:
    tuple path(splitted_csv), path(sub_data_config)

    output:
    tuple path(output), path(sub_data_config), emit: transformed_data

    script:
    output = "${splitted_csv.simpleName}-${sub_data_config.simpleName}-trans.csv"
    """
    stimulus-transform-csv -c ${splitted_csv} -y ${sub_data_config} -o ${output}
    """

    stub:
    output = "${splitted_csv.simpleName}-${sub_data_config.simpleName}-trans.csv"
    """
    touch ${output}
    """
}
