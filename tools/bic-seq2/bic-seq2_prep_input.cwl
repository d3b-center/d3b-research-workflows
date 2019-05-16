cwlVersion: v1.0
class: CommandLineTool
id: prep_bic-seq2_inputs
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/bic-seq2:0.7.2'
  - class: ResourceRequirement
    ramMin: 10000
    coresMin: 16
  - class: InlineJavascriptRequirement
baseCommand: ["/bin/bash", "-c"]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      set -eo pipefail

      for chrom in `seq 1 22` X Y; do
        echo "samtools view -@ 2 -T $(inputs.reference.path) -m $(inputs.rlen) $(inputs.input_align.path) chr$chrom | perl /samtools-0.1.7a_getUnique-0.1.3/misc/samtools.pl unique - | cut -f 4 > chr$chrom.$(inputs.stype).seq;" >> cmd_list.txt
      done

      cat cmd_list.txt | xargs -P 8 -ICMD sh -c "CMD"

inputs:
  input_align: {type: File, secondaryFiles: ['.crai']}
  reference: {type: File, secondaryFiles: [.fai]}
  stype: {type: string, doc: "input file sample type is tumor or normal"}
  rlen: {type: int, doc: "Max read length allowed. Recommend max possible read len minus 1"}
outputs:
  seq_file:
    type: File[]
    outputBinding:
      glob: '*.seq'

