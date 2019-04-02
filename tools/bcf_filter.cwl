cwlVersion: v1.0
class: CommandLineTool
id: bcf_filter
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: 'images.sbgenomics.com/luka_topalovic/bcftools:1.9'
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 2
    ramMin: 4000

baseCommand: [bcftools]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
        view -R $(inputs.SNP_list.path) $(inputs.input_gvcf.path) -i 'FORMAT/DP>=10' | bgzip > DF.$(inputs.input_gvcf.basename);
        tabix -p vcf DF.$(inputs.input_gvcf.basename);
        bcftools convert --gvcf2vcf -f $(inputs.reference_fasta.path) -R $(inputs.SNP_list.path) DF.$(inputs.input_gvcf.basename) -O v | bcftools sort -O v | bgzip > CONVERTED.$(inputs.input_gvcf.basename);
        tabix -p vcf CONVERTED.$(inputs.input_gvcf.basename);
        bcftools view -R $(inputs.SNP_list.path) CONVERTED.$(inputs.input_gvcf.basename) > SF.$(inputs.input_gvcf.nameroot);
        perl -we 'open(V,$ARGV[0]);while(<V>){s/\s+$//;if(/^\#(\#file|\#FORMAT=\<ID=GT|\#reference|\#bcftools|CHROM)/){print"$_\n";}elsif(!/^\#/){@t=split(/\t/);$h{"$t[0]\t$t[1]"}=$_ if($t[9]=~/^(0\/0|0\/1|1\/1):/);}}close(V);open(S,$ARGV[1]);while(<S>){s/\s+$//;print"$_\t.\t.\t.\tGT\t";@t=split(/\t/);if(exists$h{"$t[0]\t$t[1]"}){@s=split(/\t/,$h{"$t[0]\t$t[1]"});@u=split(/:/,$s[9]);print"$u[0]\n";}else{print"./.\n";}}close(S);' SF.$(inputs.input_gvcf.nameroot) $(inputs.SNP_list.path) > ${var fname = inputs.input_gvcf.nameroot.replace("g.vcf", inputs.SNP_list.basename + ".vcf"); return fname};

inputs:
  input_gvcf:
    type: File
    secondaryFiles: ['.tbi']
  SNP_list: File
  reference_fasta:
    type: File
    secondaryFiles: ['.fai']

outputs:
  filtered_vcf:
    type: File
    outputBinding:
      glob: |
        ${
          var fname = inputs.input_gvcf.nameroot.replace("g.vcf", inputs.SNP_list.basename + ".vcf");
          return fname
          }
