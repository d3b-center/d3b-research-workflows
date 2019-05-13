cwlVersion: v1.0
class: Workflow
id: kfdrc_bic-seq2_workflow
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
  output_basename: string

outputs:
  per_chrom_results: {type: 'File[]', outputSource: [tar_per_chrom_results/per_chrom_tumor_txt, 
  tar_per_chrom_results/per_chrom_normal_txt, tar_per_chrom_results/per_chrom_tumor_bin,
  tar_per_chrom_results/per_chrom_normal_bin, 
  tar_per_chrom_results/per_chrom_png, tar_per_chrom_results/per_chrom_cnv]}
steps:
  samtools_prep_tumor_inputs:
    run: ../../tools/bic-seq2/samtools_prep_bic-seq2_input.cwl
    in:
        input_align: input_tumor_align
        reference: reference
        ref_chrs: ref_chrs
        stype:
          valueFrom: ${return "tumor"}
        rlen: rlen
    out: [seq_file]
  samtools_prep_normal_inputs:
    run: ../../tools/bic-seq2/samtools_prep_bic-seq2_input.cwl
    in:
        input_align: input_normal_align
        reference: reference
        ref_chrs: ref_chrs
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
  bic-seq2_normalize_tumor:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge;ebs-gp2;400
    run: ../../tools/bic-seq2/bic-seq2_norm.cwl
    in:
      map_file: ubuntu_prep_intervals/map_file
      chr_ref: ubuntu_prep_intervals/chr_fa
      stype:
        valueFrom: ${return "tumor"}
      rlen: rlen
      seq_file: samtools_prep_tumor_inputs/seq_file
      scatter: [map_file, chr_ref, seq_file]
      scatterMethod: dotproduct
    out: [bin_file, output_txt]
  bic-seq2_normalize_normal:
    hints:
      - class: 'sbg:AWSInstanceType'
        value: c5.9xlarge;ebs-gp2;400
    run: ../../tools/bic-seq2/bic-seq2_norm.cwl
    in:
      map_file: ubuntu_prep_intervals/map_file
      chr_ref: ubuntu_prep_intervals/chr_fa
      stype:
        valueFrom: ${return "normal"}
      rlen: rlen
      seq_file: samtools_prep_normal_inputs/seq_file
      scatter: [map_file, chr_ref, seq_file]
      scatterMethod: dotproduct
    out: [bin_file, output_txt]
  bic-seq2_seg:
    run: ../../tools/bic-seq2/bic-seq2_seg.cwl
    in:
      case_bin: bic-seq2_normalize_tumor/bin_file
      control_bin: bic-seq2_normalize_normal/bin_file
    out: [cnv_png, out_cnv]
  tar_per_chrom_results:
    run: ../../tools/bic-seq2/ubuntu_tar_results.cwl
    in:
      output_basename: output_basename
      tumor_txt_results: bic-seq2_normalize_tumor/output_txt
      normal_txt_results: bic-seq2_normalize_normal/output_txt
      tumor_bin_results: bic-seq2_normalize_tumor/bin_file
      normal_bin_results: bic-seq2_normalize_normal/bin_file
      png_results: bic-seq2_seg/cnv_png
      cnv_results: bic-seq2_seg/out_cnv
    out:
      [per_chrom_tumor_txt, per_chrom_normal_txt, per_chrom_tumor_bin, per_chrom_normal_bin, per_chrom_png, per_chrom_cnv]


$namespaces:
  sbg: https://sevenbridges.com
hints:
  - class: 'sbg:maxNumberOfParallelInstances'
    value: 2
