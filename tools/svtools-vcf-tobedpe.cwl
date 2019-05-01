class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://sevenbridges.com'
id: svtools-vcf-tobedpe
baseCommand:
  - python /opt/svtools/vcfToBedpe
inputs:
  - id: input_vcf
    type: File
    inputBinding:
      position: 0
      prefix: '-i'
      shellQuote: false
  - id: output_name
    type: string?
    inputBinding:
      position: 2
      prefix: '-o'
      valueFrom: |-
        ${
          var output_name = inputs.output_name
          var input_name = inputs.input_vcf
          if (output_name == "")
          return input_name.path.split('/').pop().split('.')[0]+".bedpe"
          return output_name + ".bedpe"
        }
outputs:
  - id: output_bedpe
    type: File?
    outputBinding:
      glob: '*bedpe'
      outputEval: '$(inheritMetadata(self, inputs.input_vcf))'
label: svtools_vcfTobedpe
requirements:
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    ramMin: 2000
    coresMin: 1
  - class: DockerRequirement
    dockerPull: 'gaonkark/svtools:latest'
  - class: InlineJavascriptRequirement
    expressionLib:
      - |-

        var setMetadata = function(file, metadata) {
            if (!('metadata' in file))
                file['metadata'] = metadata;
            else {
                for (var key in metadata) {
                    file['metadata'][key] = metadata[key];
                }
            }
            return file
        };

        var inheritMetadata = function(o1, o2) {
            var commonMetadata = {};
            if (!Array.isArray(o2)) {
                o2 = [o2]
            }
            for (var i = 0; i < o2.length; i++) {
                var example = o2[i]['metadata'];
                for (var key in example) {
                    if (i == 0)
                        commonMetadata[key] = example[key];
                    else {
                        if (!(commonMetadata[key] == example[key])) {
                            delete commonMetadata[key]
                        }
                    }
                }
            }
            if (!Array.isArray(o1)) {
                o1 = setMetadata(o1, commonMetadata)
            } else {
                for (var i = 0; i < o1.length; i++) {
                    o1[i] = setMetadata(o1[i], commonMetadata)
                }
            }
            return o1;
        };
