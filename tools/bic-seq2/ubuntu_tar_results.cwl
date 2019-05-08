cwlVersion: v1.0
class: CommandLineTool
id: pre_map_files
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'ubuntu:18.04'
  - class: ResourceRequirement
    ramMin: 2000
    coresMin: 2
  - class: InlineJavascriptRequirement
baseCommand: ["/bin/bash", "-c"]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      set -eo pipefail
      
      tar -czf $(inputs.output_basename).tumor_txt_results.tar.gz $(inputs.tumor_txt_results.dirname) && \
      tar -czf $(inputs.output_basename).normal_txt_results.tar.gz $(inputs.normal_txt_results.dirname) && \
      tar -czf $(inputs.output_basename).tumor_bin_results.tar.gz $(inputs.tumor_bin_results.dirname) && \
      tar -czf $(inputs.output_basename).normal_bin_results.tar.gz $(inputs.normal_bin_results.dirname) && \
      tar -czf $(inputs.output_basename).png_results.tar.gz $(inputs.png_results.dirname) && \
      tar -czf $(inputs.output_basename).cnv_results.tar.gz $(inputs.cnv_results.dirname)
      
inputs:
  tumor_txt_results: File[]
  normal_txt_results: File[]
  tumor_bin_results: File[]
  normal_bin_results: File[]
  png_results: File[]
  cnv_results: File[]
  output_basename: string
outputs:
  per_chrom_tumor_txt:
    type: File
    outputBinding:
      glob: '*.tumor_txt_results.tar.gz'
  per_chrom_normal_txt:
    type: File
    outputBinding:
      glob: '*.normal_txt_results.tar.gz'
  per_chrom_tumor_bin:
    type: File
    outputBinding:
    glob: '*.tumor_bin_results.tar.gz'
  per_chrom_normal_bin:
    type: File
    outputBinding:
    glob: '*.normal_bin_results.tar.gz'
  per_chrom_png:
    type: File
    outputBinding:
      glob: '*.png_results.tar.gz'
  per_chrom_cnv:
    type: File
    outputBinding:
      glob: '*.cnv_results.tar.gz'

