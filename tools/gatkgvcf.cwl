class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: gatkgvcf
baseCommand:
  - gatk
inputs:
  - id: input_gvcf
    type: File
    inputBinding:
      position: 0
      prefix: '-V'
      shellQuote: false
    secondaryFiles:
      - .tbi
  - id: reference
    type: File
    inputBinding:
      position: 0
      prefix: '-R'
      shellQuote: false
    secondaryFiles:
      - ^.dict
      - .fai
  - id: interval
    type: File
    inputBinding:
      position: 0
      prefix: '-L'
      shellQuote: false
outputs:
  - id: output
    type: File
    outputBinding:
      glob: $(inputs.input_gvcf.nameroot).SNP_list_20190404.txt.list.vcf
label: gatkgvcf
arguments:
  - position: 0
    prefix: ''
    shellQuote: false
    valueFrom: GenotypeGVCFs
  - position: 0
    prefix: '-all-sites'
    shellQuote: false
    valueFrom: 'true'
  - position: 0
    prefix: '-O'
    shellQuote: false
    valueFrom: $(inputs.input_gvcf.nameroot).SNP_list_20190404.txt.list.vcf
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 4000
    coresMin: 1
  - class: DockerRequirement
    dockerPull: 'broadinstitute/gatk:latest'
  - class: InlineJavascriptRequirement
