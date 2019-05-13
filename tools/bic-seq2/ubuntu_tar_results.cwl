cwlVersion: v1.0
class: CommandLineTool
id: tar_results
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
      
      ${
        var base_cmd = "tar -czf " + inputs.output_basename;
        var cmd_str = base_cmd + ".tumor_txt_results.tar.gz";
        for (var file_obj in inputs.tumor_txt_results){
          cmd_str += " " + file_obj.path;
        }
        cmd_str += " && " + base_cmd + ".normal_txt_results.tar.gz";
        for (var file_obj in inputs.normal_txt_results){
          cmd_str += " " + file_obj.path;
        }
        cmd_str += " && " + base_cmd + ".tumor_bin_results.tar.gz";
        for (var file_obj in inputs.tumor_bin_results){
          cmd_str += " " + file_obj.path;
        }
        cmd_str += " && " + base_cmd + ".normal_bin_results.tar.gz";
        for (var file_obj in inputs.normal_bin_results){
          cmd_str += " " + file_obj.path;
        }
        cmd_str += " && " + base_cmd + ".png_results.tar.gz";
        for (var file_obj in inputs.png_results){
          cmd_str += " " + file_obj.path;
        }
        cmd_str += " && " + base_cmd + ".cnv_results.tar.gz";
        for (var file_obj in inputs.cnv_results){
          cmd_str += " " + file_obj.path;
        }
        return cmd_str;
      }
      
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

