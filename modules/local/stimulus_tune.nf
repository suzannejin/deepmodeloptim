process STIMULUS_TUNE {
    tag "${meta.id}"
    label 'process_high'
    container "docker.io/mathysgrapotte/stimulus-py:0.2.6"

    input:
    tuple val(meta), path(transformed_data), path(data_sub_config)
    tuple val(meta2), path(model), path(model_config), path(initial_weights)

    output:
    tuple val(meta), path("${prefix}-best-model.safetensors"), emit: model
    tuple val(meta), path("${prefix}-best-optimizer.opt")    , emit: optimizer
    tuple val(meta), path("${prefix}-best-metrics.json")     , emit: metrics
    tuple val(meta), path("${prefix}-best-tune-config.json") , emit: tune_config
    tuple val(meta), path("TuneModel_*")                     , emit: tune_experiments, optional: true

    // TODO: this is a temporary fix with tuning.py
    // it needs to be updated in stimulus-py package
    script:
    prefix = meta.id
    use_initial_weights = initial_weights != [] ? "-w ${initial_weights}" : ""
    """
    if ! ray status 2>/dev/null; then
        ray start --head --temp-dir /tmp/ray
        sleep 5
    fi

    tuning.py \
        -d ${transformed_data} \
        -m ${model} \
        -e ${data_sub_config} \
        -c ${model_config} \
        -o ${prefix}-best-model.safetensors \
        -bo ${prefix}-best-optimizer.opt \
        -bm ${prefix}-best-metrics.json \
        -bc ${prefix}-best-tune-config.json \
        ${use_initial_weights} \
        --tune_run_name ${prefix}-tune-run \
        --ray_results_dirpath "\${PWD}"
    """

    stub:
    prefix = meta.id
    """
    touch ${prefix}-best-model.safetensors
    touch ${prefix}-best-optimizer.opt
    touch ${prefix}-best-metrics.json
    touch ${prefix}-best-tune-config.json
    touch TuneModel_stub.txt
    """
}