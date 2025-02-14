
process SPLIT_DATA_CONFIG {

    tag "$data_config"
    label 'process_low'
    // TODO: push image to nf-core quay.io
    container "docker.io/mathysgrapotte/stimulus-py:0.2.6"

    input:
    path data_config

    output:
    path ("*.yaml"), emit: split_yaml

    script:
    """
    stimulus-split-yaml -j ${data_config}
    """

    stub:
    """
    touch test-split-null.yaml
    """
}
