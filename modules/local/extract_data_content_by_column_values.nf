process EXTRACT_DATA_CONTENT_BY_COLUMN_VALUES {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'nf-core/ubuntu:20.04' }"
    
    input:
    tuple val(meta), val(column_name), val(values)
    tuple val(meta2), path(data)

    output:
    tuple val(meta), path("${prefix}.${extension}"), emit: extracted_data
    path("versions.yml")                           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: []
    def separator = args.separator ?: ( data.getName().endsWith(".csv") ? ',': '\t' )
    prefix = task.ext.prefix ?: "${meta.id}.extracted"
    extension = data.getName().split("\\.").last()
    """
    # Convert comma-separated values to an array
    IFS=',' read -r -a values_array <<< $values

    # Get the column index for the given column name
    column_index=\$(head -1 $data | tr "$separator" "\\n" | nl -v 0 | grep -w $column_name | awk '{print \$1}')

    if [ -z \$column_index ]; then
        echo "Column '$column_name' not found in the CSV file."
        exit 1
    fi

    # Extract rows where the column has the specified values
    awk -v col=\$column_index -v values=$values -v FS="$separator" '
        BEGIN {
            split(values, vals, ",");
            for (i in vals) {
                val_map[vals[i]] = 1;
            }
        }
        NR == 1 || val_map[\$(col + 1)] {
            print \$0
        }
    ' $data > ${prefix}.${extension}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bash: \$(echo \$(bash --version | grep -Eo 'version [[:alnum:].]+' | sed 's/version //'))
    END_VERSIONS
    """
}