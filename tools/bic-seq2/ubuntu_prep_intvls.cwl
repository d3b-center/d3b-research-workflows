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

inputs:
  interval_list: {type: File, doc: "Can be bed or gatk interval_list"}
outputs:
  map_file:
    type: File[]
    outputBinding:
      glob: '*.txt'

