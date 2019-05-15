cwlVersion: v1.0
class: CommandLineTool
id: bic-seq2_norm
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/bic-seq2:0.7.2'
  - class: ResourceRequirement
    ramMin: 4000
    coresMin: 2
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      export CONFIG_FILE=norm_config.txt &&
      echo "chromName\tfaFile\tMapFile\treadPosFile\tbinFileNorm" > $CONFIG_FILE &&
      echo "$(inputs.chr_ref.nameroot)\t$(inputs.chr_ref.path)\t$(inputs.map_file.path)\t$(inputs.seq_file.path)\t$(inputs.chr_ref.nameroot).$(inputs.stype).bin" >> $CONFIG_FILE &&
      perl /NBICseq-norm_v0.2.4/NBICseq-norm.pl
      --tmp TMP
      -l $(inputs.rlen)
      -s 350
      -b 100
      $CONFIG_FILE
      $(inputs.chr_ref.nameroot).$(inputs.stype)_output.txt

inputs:
  map_file: {type: File, doc: "TSV with star and end coords from a single chromosome"}
  chr_ref: {type: File, doc: "single chromosome fasta file"}
  stype: {type: string, doc: "input file sample type is tumor or normal"}
  rlen: {type: int, doc: "Max read length allowed. Recommend max possible read len minus 1"}
  seq_file: File
outputs:
  bin_file:
    type: File
    outputBinding:
      glob: '*.bin'
