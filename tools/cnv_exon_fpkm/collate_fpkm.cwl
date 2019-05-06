class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: collate_fpkm
baseCommand:
  - Rscript /opt/collate.R
inputs:
  - id: input_cov
    type: File?
    inputBinding:
      position: 1
    label: coverage file from bedcov
  - id: input_flagstat
    type: File?
    inputBinding:
      position: 2
    label: flagstat file format
outputs:
  - id: output
    type: File?
    outputBinding:
      glob: '*_FPKM.txt'
      outputEval: '$(inheritMetadata(self, inputs.input_cov))'
label: collate_fpkm
requirements:
  - class: ResourceRequirement
    ramMin: 2000
    coresMin: 1
  - class: DockerRequirement
    dockerPull: 'gaonkark/collate_fpkm:latest'
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
