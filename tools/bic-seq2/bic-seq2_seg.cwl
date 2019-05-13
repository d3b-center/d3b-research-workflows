cwlVersion: v1.0
class: CommandLineTool
id: prep_bic-seq2_inputs
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'kfdrc/bic-seq2:0.7.2'
  - class: ResourceRequirement
    ramMin: 10000
    coresMin: 4
  - class: InlineJavascriptRequirement
baseCommand: []
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      export CHROM=$(inputs.case_bin.nameroot.split(".")[0]);
      echo -e "chromName\tbinFileNorm.Case\tbinFileNorm.Control" > seg_config.txt &&
      echo -e "$CHROM\t$(inputs.case_bin.path)\t$(inputs.control_bin.path)" >> seg_config.txt &&
      perl /NBICseq-seg_v0.7.2/NBICseq-seg.pl
      --detail 
      --control
      --fig $CHROM.png
      seg_config.txt
      $CHROM.CNV


inputs:
  case_bin: {type: File, doc: "Tumor bin file from bic-seq2 norm"}
  control_bin: {type: File, doc: "Normal bin file from bic-seq2 norm"}
outputs:
  cnv_png:
    type: File
    outputBinding:
      glob: '*.png'
  out_cnv:
    type: File
    outputBinding:
      glob: '*.CNV'
 