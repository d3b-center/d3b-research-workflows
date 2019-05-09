class: Workflow
cwlVersion: v1.0
id: kfdrc-harmonization/sd-8y99qzjj/bedcov-fpkm/0
label: bedcov_fpkm
$namespaces:
  sbg: 'https://sevenbridges.com'
inputs:
  - id: input_bed
    'sbg:fileTypes': bed
    type: File
    'sbg:x': -506
    'sbg:y': -130
  - id: input_cram
    type: File
    'sbg:x': -510.58209228515625
    'sbg:y': 128.04476928710938
outputs:
  - id: fpkm_output
    outputSource:
      - collate_fpkm/output
    type: File?
    'sbg:x': 248.1556854248047
    'sbg:y': -8.134627342224121
  - id: output_cov_file
    outputSource:
      - bedcov_flagstaff/output_cov_file
    type: File?
    'sbg:x': 198.1556854248047
    'sbg:y': -236.1259765625
  - id: flagstat_output
    outputSource:
      - bedcov_flagstaff/output
    type: File?
    'sbg:x': 183.1556854248047
    'sbg:y': 194.87400817871094
steps:
  - id: collate_fpkm
    in:
      - id: input_cov
        source: bedcov_flagstaff/output_cov_file
      - id: input_flagstat
        source: bedcov_flagstaff/output
    out:
      - id: output
    run:
      class: CommandLineTool
      cwlVersion: v1.0
      $namespaces:
        sbg: 'https://sevenbridges.com'
      id: gaonkark/cbttc-0012a-cell-line/collate-fpkm/0
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
      'sbg:appVersion':
        - v1.0
      'sbg:id': gaonkark/cbttc-0012a-cell-line/collate-fpkm/0
      'sbg:revision': 0
      'sbg:revisionNotes': null
      'sbg:modifiedOn': 1557152424
      'sbg:modifiedBy': gaonkark
      'sbg:createdOn': 1557152424
      'sbg:createdBy': gaonkark
      'sbg:project': gaonkark/cbttc-0012a-cell-line
      'sbg:projectName': CBTTC_0012a cell line
      'sbg:sbgMaintained': false
      'sbg:validationErrors': []
      'sbg:contributors':
        - gaonkark
      'sbg:latestRevision': 0
      'sbg:revisionsInfo':
        - 'sbg:revision': 0
          'sbg:modifiedBy': gaonkark
          'sbg:modifiedOn': 1557152424
          'sbg:revisionNotes': null
      'sbg:image_url': null
      'sbg:publisher': sbg
      'sbg:content_hash': a0fd2dfa8a14656b1874de40330dda4a7e07ebab398de2dcab41a26c739a51957
    label: collate_fpkm
    'sbg:x': -11
    'sbg:y': -7
  - id: bedcov_flagstaff
    in:
      - id: input
        source: input_cram
      - id: input_bed
        source: input_bed
    out:
      - id: output_cov_file
      - id: output
    run:
      class: Workflow
      cwlVersion: v1.0
      id: gaonkark/cbttc-0012a-cell-line/bedcov-flagstaff/1
      label: bedcov_flagstaff
      $namespaces:
        sbg: 'https://sevenbridges.com'
      inputs:
        - id: input
          type: File
          'sbg:x': -372
          'sbg:y': 71
        - id: input_bed
          'sbg:fileTypes': bed
          type: File
          'sbg:x': -378
          'sbg:y': -78
      outputs:
        - id: output_cov_file
          outputSource:
            - samtools_bedcov_4/output_cov_file
          type: File?
          'sbg:x': 57
          'sbg:y': -8
        - id: output
          outputSource:
            - samtools_index_cram/output
          type: File?
          'sbg:x': 64.59024047851562
          'sbg:y': 132.45880126953125
      steps:
        - id: samtools_bedcov_4
          in:
            - id: input_bam_file
              source: input
            - id: input_bed
              source: input_bed
          out:
            - id: output_cov_file
          run:
            class: CommandLineTool
            cwlVersion: v1.0
            $namespaces:
              sbg: 'https://sevenbridges.com'
            id: gaonkark/cbttc-0012a-cell-line/samtools-bedcov-4/3
            baseCommand:
              - samtools bedcov
            inputs:
              - id: input_bam_file
                type: File
                inputBinding:
                  position: 1
                'sbg:fileTypes': 'cram, bam'
                secondaryFiles:
                  - .crai
              - id: input_bed
                type: File
                inputBinding:
                  position: 0
                'sbg:fileTypes': bed
            outputs:
              - id: output_cov_file
                type: File?
                outputBinding:
                  glob: '*txt'
                  outputEval: '$(inheritMetadata(self, inputs.input_bam_file))'
            label: samtools_bedcov
            arguments:
              - position: 3
                prefix: ''
                shellQuote: false
                valueFrom: |-
                  ${
                    var input_name = inputs.input_bam_file
                    var input_bed =inputs.input_bed
                    return "> "+input_name.path.split('/').pop().split('.')[0]+"_"+input_bed.path.split('/').pop().split('.')[0]+".coverage.txt"
                  }
            requirements:
              - class: ShellCommandRequirement
              - class: ResourceRequirement
                ramMin: 20
                coresMin: 0
              - class: DockerRequirement
                dockerPull: 'quay.io/biocontainers/samtools:1.9--h8571acd_11'
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
            hints:
              - class: 'sbg:AWSInstanceType'
                value: c4.8xlarge
            'sbg:projectName': CBTTC_0012a cell line
            'sbg:revisionsInfo':
              - 'sbg:revision': 0
                'sbg:modifiedBy': gaonkark
                'sbg:modifiedOn': 1557030198
                'sbg:revisionNotes': Copy of gaonkark/cnmc-test-space/samtools-bedcov/4
              - 'sbg:revision': 1
                'sbg:modifiedBy': gaonkark
                'sbg:modifiedOn': 1557088381
                'sbg:revisionNotes': ''
              - 'sbg:revision': 2
                'sbg:modifiedBy': gaonkark
                'sbg:modifiedOn': 1557093119
                'sbg:revisionNotes': ''
              - 'sbg:revision': 3
                'sbg:modifiedBy': gaonkark
                'sbg:modifiedOn': 1557093426
                'sbg:revisionNotes': ''
            'sbg:image_url': null
            'sbg:appVersion':
              - v1.0
            'sbg:id': gaonkark/cbttc-0012a-cell-line/samtools-bedcov-4/3
            'sbg:revision': 3
            'sbg:revisionNotes': ''
            'sbg:modifiedOn': 1557093426
            'sbg:modifiedBy': gaonkark
            'sbg:createdOn': 1557030198
            'sbg:createdBy': gaonkark
            'sbg:project': gaonkark/cbttc-0012a-cell-line
            'sbg:sbgMaintained': false
            'sbg:validationErrors': []
            'sbg:contributors':
              - gaonkark
            'sbg:latestRevision': 3
            'sbg:publisher': sbg
            'sbg:content_hash': aa8dfde1e63c5763fc45de2018b1d47c19a11b9a970dd93797acc4c33078801ac
          label: samtools_bedcov
          'sbg:x': -145
          'sbg:y': -5
        - id: samtools_index_cram
          in:
            - id: input
              source: input
          out:
            - id: output
          run:
            class: CommandLineTool
            cwlVersion: v1.0
            $namespaces:
              sbg: 'https://sevenbridges.com'
            id: gaonkark/cbttc-0012a-cell-line/samtools-index-cram/4
            baseCommand:
              - samtools flagstat
            inputs:
              - id: input
                type: File
                inputBinding:
                  position: 0
            outputs:
              - id: output
                type: File?
                outputBinding:
                  glob: '*.txt'
                  outputEval: '$(inheritMetadata(self, inputs.input))'
                secondaryFiles:
                  - .crai
            label: samtools_flagstat_cram
            arguments:
              - position: 3
                prefix: ''
                shellQuote: false
                valueFrom: |-
                  ${
                    var input_name = inputs.input
                    return "> "+input_name.path.split('/').pop().split('.')[0]+".flagstat.txt"
                  }
            requirements:
              - class: ShellCommandRequirement
              - class: ResourceRequirement
                ramMin: 20
              - class: DockerRequirement
                dockerPull: 'quay.io/biocontainers/samtools:1.9--h8571acd_11'
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
            hints:
              - class: 'sbg:AWSInstanceType'
                value: c4.8xlarge
            'sbg:projectName': CBTTC_0012a cell line
            'sbg:revisionsInfo':
              - 'sbg:revision': 0
                'sbg:modifiedBy': gaonkark
                'sbg:modifiedOn': 1557020337
                'sbg:revisionNotes': null
              - 'sbg:revision': 1
                'sbg:modifiedBy': gaonkark
                'sbg:modifiedOn': 1557020422
                'sbg:revisionNotes': ''
              - 'sbg:revision': 2
                'sbg:modifiedBy': gaonkark
                'sbg:modifiedOn': 1557028256
                'sbg:revisionNotes': ''
              - 'sbg:revision': 3
                'sbg:modifiedBy': gaonkark
                'sbg:modifiedOn': 1557028839
                'sbg:revisionNotes': ''
              - 'sbg:revision': 4
                'sbg:modifiedBy': gaonkark
                'sbg:modifiedOn': 1557094681
                'sbg:revisionNotes': ''
            'sbg:image_url': null
            'sbg:appVersion':
              - v1.0
            'sbg:id': gaonkark/cbttc-0012a-cell-line/samtools-index-cram/4
            'sbg:revision': 4
            'sbg:revisionNotes': ''
            'sbg:modifiedOn': 1557094681
            'sbg:modifiedBy': gaonkark
            'sbg:createdOn': 1557020337
            'sbg:createdBy': gaonkark
            'sbg:project': gaonkark/cbttc-0012a-cell-line
            'sbg:sbgMaintained': false
            'sbg:validationErrors': []
            'sbg:contributors':
              - gaonkark
            'sbg:latestRevision': 4
            'sbg:publisher': sbg
            'sbg:content_hash': aaabfb0d551729aa419472e5946aada338c0878215cf2d9bc5faac57b9b6841a9
          label: samtools_flagstat_cram
          'sbg:x': -128
          'sbg:y': 130
      requirements: []
      'sbg:projectName': CBTTC_0012a cell line
      'sbg:revisionsInfo':
        - 'sbg:revision': 0
          'sbg:modifiedBy': gaonkark
          'sbg:modifiedOn': 1557144921
          'sbg:revisionNotes': null
        - 'sbg:revision': 1
          'sbg:modifiedBy': gaonkark
          'sbg:modifiedOn': 1557145004
          'sbg:revisionNotes': ''
      'sbg:image_url': >-
        https://cavatica.sbgenomics.com/ns/brood/images/gaonkark/cbttc-0012a-cell-line/bedcov-flagstaff/1.png
      'sbg:appVersion':
        - v1.0
      'sbg:id': gaonkark/cbttc-0012a-cell-line/bedcov-flagstaff/1
      'sbg:revision': 1
      'sbg:revisionNotes': ''
      'sbg:modifiedOn': 1557145004
      'sbg:modifiedBy': gaonkark
      'sbg:createdOn': 1557144921
      'sbg:createdBy': gaonkark
      'sbg:project': gaonkark/cbttc-0012a-cell-line
      'sbg:sbgMaintained': false
      'sbg:validationErrors': []
      'sbg:contributors':
        - gaonkark
      'sbg:latestRevision': 1
      'sbg:publisher': sbg
      'sbg:content_hash': a2b2b0c9a7de609ce44c51f12a69f63d2f46cd0da889a60fd244b502a48945730
    label: bedcov_flagstaff
    'sbg:x': -240
    'sbg:y': -3
requirements:
  - class: SubworkflowFeatureRequirement
'sbg:projectName': PNOC008 Harmonization
'sbg:revisionsInfo':
  - 'sbg:revision': 0
    'sbg:modifiedBy': gaonkark
    'sbg:modifiedOn': 1557411139
    'sbg:revisionNotes': Copy of gaonkark/cbttc-0012a-cell-line/bedcov-fpkm/1
'sbg:image_url': >-
  https://cavatica.sbgenomics.com/ns/brood/images/kfdrc-harmonization/sd-8y99qzjj/bedcov-fpkm/0.png
'sbg:appVersion':
  - v1.0
'sbg:id': kfdrc-harmonization/sd-8y99qzjj/bedcov-fpkm/0
'sbg:revision': 0
'sbg:revisionNotes': Copy of gaonkark/cbttc-0012a-cell-line/bedcov-fpkm/1
'sbg:modifiedOn': 1557411139
'sbg:modifiedBy': gaonkark
'sbg:createdOn': 1557411139
'sbg:createdBy': gaonkark
'sbg:project': kfdrc-harmonization/sd-8y99qzjj
'sbg:sbgMaintained': false
'sbg:validationErrors': []
'sbg:contributors':
  - gaonkark
'sbg:latestRevision': 0
'sbg:publisher': sbg
'sbg:content_hash': a0c930157c9c5b194d6fd6810f11d16b432cf40569243cb3d59de0e7666dda29b
'sbg:copyOf': gaonkark/cbttc-0012a-cell-line/bedcov-fpkm/1
