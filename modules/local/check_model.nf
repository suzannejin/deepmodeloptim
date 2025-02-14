
process CHECK_MODEL {

    tag "$data_config - $data"
    label 'process_medium'
    // TODO: push image to nf-core quay.io
    container "docker.io/mathysgrapotte/stimulus-py:0.2.6"
    containerOptions '--shm-size=2gb'

    input:
    tuple path(data), path(model),  path(data_config), path(model_config)//, path(initial_weights)

    output:
    stdout emit: standardout

    script:
    def args = task.ext.args ?: ''
    """
    if ! ray status 2>/dev/null; then
        ray start --head --temp-dir /tmp/ray
        sleep 5
    fi

    sleep 5

    export RAY_ADDRESS=localhost:6379

    stimulus-check-model \
        -e ${data_config} \
        -d ${data} \
        -m ${model} \
        -c ${model_config} \
        $args

    """

    stub:
    """
    echo passing
    """
}