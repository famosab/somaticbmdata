process GENOMEVARIATOR_ALIGNMENTSPLITTER {
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://ghcr.io/Computational-Genomics-BSC/genomevariator:latest' :
        'ghcr.io/Computational-Genomics-BSC/genomevariator:latest' }"

    input:
    tuple val(meta), path(input), val(input_coverage), val(output_coverage), val(sample_count)
    tuple val(meta2), path(reference)

    output:
    tuple val(meta), path("*.cram"), emit: cram
    path "versions.yml"        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def seed = 0
    def VERSION = "1.0.2" // WARN: Version information not provided by tool on CLI. Please update version string below when bumping container versions.
    """
    alignment_splitter.py \\
        --input $input \\
        --fasta $reference \\
        --input-coverage $input_coverage \\
        --output $prefix \\
        --output-coverages $output_coverage \\
        --sample-count $sample_count \\
        --max-processes ${task.cpus} \\
        --seed $seed \\
        $args

    mv ${prefix}0_${output_coverage}X_0

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        GenomeVariator: $VERSION
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = "1.0.2" // WARN: Version information not provided by tool on CLI. Please update version string below when bumping container versions.
    """
    mkdir multiqc_data
    touch multiqc_plots
    touch multiqc_report.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        GenomeVariator: $VERSION
    END_VERSIONS
    """
}
