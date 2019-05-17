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
        var tar_cmd = "tar -czf " + inputs.output_basename;
        var png_dir = inputs.output_basename + "_png_results/";
        var cmd_str = "mkdir " + png_dir + " && ";
        inputs.png_results.forEach(function(file_obj){
          cmd_str += "cp " + file_obj.path + " " + png_dir + inputs.output_basename + "." + file_obj.basename + " && ";
        });
        cmd_str += tar_cmd + ".png_results.tar.gz " + png_dir + " && ";
        cmd_str += " echo \"chrom\tstart\tend\tbinNum\ttumor\ttumor_expect\tnormal\tnormal_expect\tlog2.copyRatio\tlog2.TumorExpectRatio\" > " + inputs.output_basename + ".merged.CNV";
        inputs.cnv_results.forEach(function(file_obj){
          cmd_str += " && cat " + file_obj.path + " | grep -v chrom >> " + inputs.output_basename + ".merged.CNV";
        });
        return cmd_str;
      }
      
inputs:
  png_results: File[]
  cnv_results: File[]
  output_basename: string
outputs:
  per_chrom_png:
    type: File
    outputBinding:
      glob: '*.png_results.tar.gz'
  merged_chrom_cnv:
    type: File
    outputBinding:
      glob: '*.merged.CNV'

