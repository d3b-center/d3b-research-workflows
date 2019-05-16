cwlVersion: v1.0
class: Workflow
id: bic-seq2-input-prep
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  input_tumor_align: {type: File, secondaryFiles: ['.crai']}
  input_normal_align: {type: File, secondaryFiles: ['.crai']}
  reference: {type: File, secondaryFiles: [.fai]}
  ref_chrs: {type: File, doc: "Tar gzipped per-chromosome fasta"}
  rlen: {type: int, doc: "Max read length allowed. Recommend max possible read len minus 1"}
  interval_list: {type: File, doc: "Can be bed or gatk interval_list"}

outputs:
  tumor_seq: {type: 'File[]', outputSource: bic-seq2_prep_tumor_inputs/seq_file}
  normal_seq: {type: 'File[]', outputSource: bic-seq2_prep_normal_inputs/seq_file}
  map_file: {type: 'File[]', outputSource: ubuntu_prep_intervals/map_file}
  chr_fa: {type: 'File[]', outputSource: ubuntu_prep_intervals/chr_fa}
steps:
  bic-seq2_prep_tumor_inputs:
    run: ../../tools/bic-seq2/bic-seq2_prep_input.cwl
    in:
      input_align: input_tumor_align
      reference: reference
      stype:
        valueFrom: ${return "tumor"}
      rlen: rlen
    out: [seq_file]
  bic-seq2_prep_normal_inputs:
    run: ../../tools/bic-seq2/bic-seq2_prep_input.cwl
    in:
      input_align: input_normal_align
      reference: reference
      stype:
        valueFrom: ${return "normal"}
      rlen: rlen
    out: [seq_file]
  ubuntu_prep_intervals:
    run: ../../tools/bic-seq2/ubuntu_prep_intvls.cwl
    in:
      interval_list: interval_list
      ref_chrs: ref_chrs
    out: [map_file, chr_fa]

$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 2
