
process CHECK_MODEL {

    tag "check model"
    label 'process_medium'
    // TODO: push image to nf-core quay.io
    container "docker.io/mathysgrapotte/stimulus-py:0.2.6"
    containerOptions '--shm-size=2gb'

    input:
    tuple val(meta), path(data_config)
    tuple val(meta2), path(data)
    tuple val(meta3), path(model)
    tuple val(meta4), path(model_config)
    tuple val(meta5), path(initial_weights)

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
        --ray_results_dirpath "\${PWD}" \
        $args
    """

    stub:
    """
    echo passing check-model stub
    """
}
