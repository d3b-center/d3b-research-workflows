cwlVersion: v1.0
class: Workflow
id: bcf_call
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  input_align: File[]
  chr_list: File
  reference_fasta: File
  snp_bed: File

outputs:
  bcf_called_vcf: {type: File, outputSource: bcf_filter/bcf_call}

steps:
  bcf_filter:
    run: ../tools/bcf_filter.cwl
    in:
      input_align: input_align
      chr_list: chr_list
      reference_fasta: reference_fasta
      snp_bed: snp_bed
    scatter: [input_align]
    out: [bcf_call]


$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:AWSInstanceType'
    value: c5.9xlarge;ebs-gp2;850
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 4