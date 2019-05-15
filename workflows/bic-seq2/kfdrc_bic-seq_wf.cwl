cwlVersion: v1.0
class: Workflow
id: kfdrc_bic-seq2_workflow
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  input_tumor_align: {type: File, secondaryFiles: ['.crai']}
  input_normal_align: {type: File, secondaryFiles: ['.crai']}
  reference: {type: File, secondaryFiles: [.fai]}
  ref_chrs: {type: File, doc: "Tar gzipped per-chromosome fasta"}
  rlen: {type: int, doc: "Max read length allowed. Recommend max possible read len minus 1"}
  interval_list: {type: File, doc: "Can be bed or gatk interval_list"}
  output_basename: string

outputs:
  per_chrom_png: {type: File, outputSource: tar_per_chrom_results/per_chrom_png}
  merge_cnv_results: {type: File, outputSource: tar_per_chrom_results/merged_chrom_cnv}
steps:
  prep_input_subwf:
    run: ./kfdrc_input_prep_subwf.cwl
    in:
      input_tumor_align: input_tumor_align
      input_normal_align: input_normal_align
      reference: reference
      ref_chrs: ref_chrs
      rlen: rlen
      interval_list: interval_list
    out: [tumor_seq, normal_seq, map_file, chr_fa]
  bic-seq2_normalize_tumor:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge;ebs-gp2;400
    run: ../../tools/bic-seq2/bic-seq2_norm.cwl
    in:
      map_file: prep_input_subwf/map_file
      chr_ref: prep_input_subwf/chr_fa
      stype:
        valueFrom: ${return "tumor"}
      rlen: rlen
      seq_file: prep_input_subwf/tumor_seq
    scatter: [map_file, chr_ref, seq_file]
    scatterMethod: dotproduct
    out: [bin_file]
  bic-seq2_normalize_normal:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge;ebs-gp2;400
    run: ../../tools/bic-seq2/bic-seq2_norm.cwl
    in:
      map_file: prep_input_subwf/map_file
      chr_ref: prep_input_subwf/chr_fa
      stype:
        valueFrom: ${return "normal"}
      rlen: rlen
      seq_file: prep_input_subwf/normal_seq
    scatter: [map_file, chr_ref, seq_file]
    scatterMethod: dotproduct
    out: [bin_file]
  bic-seq2_seg:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge;ebs-gp2;400
    run: ../../tools/bic-seq2/bic-seq2_seg.cwl
    in:
      case_bin: bic-seq2_normalize_tumor/bin_file
      control_bin: bic-seq2_normalize_normal/bin_file
    scatter: [case_bin, control_bin]
    scatterMethod: dotproduct
    out: [cnv_png, out_cnv]
  tar_per_chrom_results:
    run: ../../tools/bic-seq2/ubuntu_tar_results.cwl
    in:
      output_basename: output_basename
      png_results: bic-seq2_seg/cnv_png
      cnv_results: bic-seq2_seg/out_cnv
    out:
      [per_chrom_png, merged_chrom_cnv]


$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 3
