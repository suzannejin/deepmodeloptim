process STIMULUS_TUNE {
    tag "${sub_data_config.simpleName}"
    label 'process_high'
    container "docker.io/mathysgrapotte/stimulus-py:0.2.6"
    input:
    tuple path(transformed_data), path(sub_data_config), path(model), path(model_config)
    output:
    tuple path("${sub_data_config.simpleName}-best-model.safetensors"), path("${sub_data_config.simpleName}-best-optimizer.opt"), path("${sub_data_config.simpleName}-best-metrics.json"), path("${sub_data_config.simpleName}-best-tune-config.json"), path("TuneModel_*"),emit: tune_specs
    script:
    """
    if ! ray status 2>/dev/null; then
        ray start --head --temp-dir /tmp/ray
        sleep 5
    fi

    tuning.py \
            -d ${transformed_data} \
            -m ${model} \
            -e ${sub_data_config} \
            -c ${model_config} \
            -o ${sub_data_config.simpleName}-best-model.safetensors \
            -bo ${sub_data_config.simpleName}-best-optimizer.opt \
            -bm ${sub_data_config.simpleName}-best-metrics.json \
            -bc ${sub_data_config.simpleName}-best-tune-config.json \
            --tune_run_name ${sub_data_config.simpleName}-tune-run \
            --ray_results_dirpath "\${PWD}"
    """
}