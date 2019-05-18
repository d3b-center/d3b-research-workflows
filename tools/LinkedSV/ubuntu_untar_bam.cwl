cwlVersion: v1.0
class: CommandLineTool
id: ubuntu_untar
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'migbro/ubuntu_pigz:latest'
  - class: ResourceRequirement
    ramMin: 8000
    coresMin: 8
  - class: InlineJavascriptRequirement
baseCommand: [tar -xf]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      $(inputs.tar_gz.path)
      --use-compress-program=pigz
      outs/phased_possorted_bam.bam
      
      mv outs/phased_possorted_bam.bam $(inputs.output_basename).phased_possorted_bam.bam
inputs:
  output_basename: string
  tar_gz: {type: File, doc: "tar gzipped outputs from X10 longranger"}
outputs:
  extracted_bam:
    type: File
    outputBinding:
      glob: '*.bam'
