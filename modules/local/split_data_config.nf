
process SPLIT_DATA_CONFIG {

    tag "$data_config"
    label 'process_low'
    // TODO: push image to nf-core quay.io
    container "docker.io/mathysgrapotte/stimulus-py:0.2.6"

    input:
    path data_config

    output:
    path ("*.yaml"), emit: sub_config

    script:
    """
    stimulus-split-yaml -j ${data_config}
    """

    stub:
    """
    touch test_0.yaml
    touch test_1.yaml
    touch test_2.yaml
    """
}
