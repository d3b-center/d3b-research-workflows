cwlVersion: v1.0
class: CommandLineTool
id: linkedsv
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'migbro/linkedsv:latest'
  - class: ResourceRequirement
    ramMin: 36000
    coresMin: 16
  - class: InlineJavascriptRequirement
baseCommand: [python]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      /LinkedSV/linkedsv.py
      -i $(inputs.bam.path)
      -d $(inputs.output_basename)
      -r $(inputs.ref.path)
      -t 16
      ${
          var added_cmd = " --" + inputs.detect_mode
          if (typeof inputs.ref_version !== 'undefined' || inputs.ref_version !== null){
              added_cmd += " --ref_version " + inputs.ref_version.path;
          }
          if (typeof inputs.gap_region_bed !== 'undefined' || inputs.gap_region_bed !== null){
              added_cmd += " --gap_region_bed " + inputs.gap_region_bed.path;
          }
          if (typeof inputs.black_region_bed !== 'undefined' || inputs.black_region_bed !== null){
              added_cmd += " --black_region_bed " + inputs.black_region_bed.path;
          }
          if (typeof inputs.target_region !== 'undefined' || inputs.target_region !== null){
              added_cmd += " --target_region " + inputs.target_region.path;
          }
          if (typeof inputs.min_fragment_length !== 'undefined' || inputs.min_fragment_length !== null){
              added_cmd += " --min_fragment_length " + inputs.min_fragment_length;
          }
          if (typeof inputs.min_reads_in_fragment !== 'undefined' || inputs.min_reads_in_fragment !== null){
              added_cmd += " --min_reads_in_fragment " + inputs.min_reads_in_fragment;
          }
          if (typeof inputs.input_type !== 'undefined' || inputs.input_type !== null){
              added_cmd += " --" + inputs.input_type;
          }
          if (typeof inputs.ap_distance_cut_off !== 'undefined' || inputs.ap_distance_cut_off !== null){
              added_cmd += " --ap_distance_cut_off " + inputs.ap_distance_cut_off;
          }
          return added_cmd;
      }

      tar -czf $(inputs.output_basename).tar.gz

inputs:
  output_basename: string
  bam: {type: File, doc: "phased_possorted_bam.bam"}
  ref: {type: File, doc: "reference FASTA file"}
  ref_version: {type: ['null', string], doc: "version of reference fasta file. Current supported versions are: hg19, b37, hg38"}
  detect_mode: {type: string, doc: "detection mode, accepted values are germline_mode, somatic_mode"}
  input_type: {type: ['null', string], doc: "accepted values wgs, targeted"}
  gap_region_bed: {type: ['null', File], doc: "reference gap region in bed format"}
  black_region_bed: {type: ['null', File], doc: "black region in bed format"}
  target_region: {type: ['null', File], doc: "bed file of target regions (required if --targeted is specified)"}
  min_fragment_length: {type: ['null', int], doc: "minimal fragment length considered for SV calling"}
  min_reads_in_fragment: {type: ['null', int], doc: "minimal number of confidently mapped reads in one fragment"}
  min_supp_barcodes: {type: ['null', int], doc: "minimal number of shared barcodes between two SV breakpoints (default: 10)"}
  ap_distance_cut_off: {type: ['null', int], doc: "max distance between two reads in a HMW DNA molecule (default: automatically determined)"}
  
outputs:
  results_tarball:
    type: File
    outputBinding:
      glob: '*.tar.gz'
 