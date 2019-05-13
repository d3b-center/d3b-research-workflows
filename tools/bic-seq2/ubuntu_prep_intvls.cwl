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

      for chrom in `seq 1 22` X Y; do
        grep -E "^chr$chrom\s+" $(inputs.interval_list.path) | cut -f 2,3 > chr$chrom.mappability.txt
      done

      tar -xzf $(inputs.ref_chrs.path)

      rm $(inputs.ref_chrs.nameroot.substring(0,(inputs.ref_chrs.nameroot.length-4)))/chrM.fa
inputs:
  interval_list: {type: File, doc: "Can be bed or gatk interval_list"}
  ref_chrs: {type: File, doc: "Tar gzipped per-chromosome fasta"}
outputs:
  map_file:
    type: File[]
    outputBinding:
      glob: '*.txt'
  chr_fa:
    type: File[]
    outputBinding:
      glob: "$(inputs.ref_chrs.nameroot.substring(0,(inputs.ref_chrs.nameroot.length-4)))/*.fa"
