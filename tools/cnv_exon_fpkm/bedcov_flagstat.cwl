{
  "class": "Workflow",
  "cwlVersion": "v1.0",
  "label": "bedcov_flagstat",
  "$namespaces": {
    "sbg": "https://sevenbridges.com"
  },
  "inputs": [
    {
      "id": "input",
      "type": "File",
      "sbg:x": -372,
      "sbg:y": 71
    },
    {
      "id": "input_bed",
      "sbg:fileTypes": "bed",
      "type": "File",
      "sbg:x": -378,
      "sbg:y": -78
    }
  ],
  "outputs": [
    {
      "id": "output_cov_file",
      "outputSource": [
        "samtools_bedcov_4/output_cov_file"
      ],
      "type": "File?",
      "sbg:x": 57,
      "sbg:y": -8
    },
    {
      "id": "output",
      "outputSource": [
        "samtools_index_cram/output"
      ],
      "type": "File?",
      "sbg:x": 64.59024047851562,
      "sbg:y": 132.45880126953125
    }
  ],
  "steps": [
    {
      "id": "samtools_bedcov_4",
      "in": [
        {
          "id": "input_bam_file",
          "source": "input"
        },
        {
          "id": "input_bed",
          "source": "input_bed"
        }
      ],
      "out": [
        {
          "id": "output_cov_file"
        }
      ],
      "run": {
        "class": "CommandLineTool",
        "cwlVersion": "v1.0",
        "$namespaces": {
          "sbg": "https://sevenbridges.com"
        },
        "id": "gaonkark/cbttc-0012a-cell-line/samtools-bedcov-4/3",
        "baseCommand": [
          "samtools bedcov"
        ],
        "inputs": [
          {
            "id": "input_bam_file",
            "type": "File",
            "inputBinding": {
              "position": 1
            },
            "sbg:fileTypes": "cram, bam",
            "secondaryFiles": [
              ".crai"
            ]
          },
          {
            "id": "input_bed",
            "type": "File",
            "inputBinding": {
              "position": 0
            },
            "sbg:fileTypes": "bed"
          }
        ],
        "outputs": [
          {
            "id": "output_cov_file",
            "type": "File?",
            "outputBinding": {
              "glob": "*txt",
              "outputEval": "$(inheritMetadata(self, inputs.input_bam_file))"
            }
          }
        ],
        "label": "samtools_bedcov",
        "arguments": [
          {
            "position": 3,
            "prefix": "",
            "shellQuote": false,
            "valueFrom": "${\n  var input_name = inputs.input_bam_file\n  var input_bed =inputs.input_bed\n  return \"> \"+input_name.path.split('/').pop().split('.')[0]+\"_\"+input_bed.path.split('/').pop().split('.')[0]+\".coverage.txt\"\n}"
          }
        ],
        "requirements": [
          {
            "class": "ShellCommandRequirement"
          },
          {
            "class": "ResourceRequirement",
            "ramMin": 20,
            "coresMin": 0
          },
          {
            "class": "DockerRequirement",
            "dockerPull": "quay.io/biocontainers/samtools:1.9--h8571acd_11"
          },
          {
            "class": "InlineJavascriptRequirement",
            "expressionLib": [
              "\nvar setMetadata = function(file, metadata) {\n    if (!('metadata' in file))\n        file['metadata'] = metadata;\n    else {\n        for (var key in metadata) {\n            file['metadata'][key] = metadata[key];\n        }\n    }\n    return file\n};\n\nvar inheritMetadata = function(o1, o2) {\n    var commonMetadata = {};\n    if (!Array.isArray(o2)) {\n        o2 = [o2]\n    }\n    for (var i = 0; i < o2.length; i++) {\n        var example = o2[i]['metadata'];\n        for (var key in example) {\n            if (i == 0)\n                commonMetadata[key] = example[key];\n            else {\n                if (!(commonMetadata[key] == example[key])) {\n                    delete commonMetadata[key]\n                }\n            }\n        }\n    }\n    if (!Array.isArray(o1)) {\n        o1 = setMetadata(o1, commonMetadata)\n    } else {\n        for (var i = 0; i < o1.length; i++) {\n            o1[i] = setMetadata(o1[i], commonMetadata)\n        }\n    }\n    return o1;\n};"
            ]
          }
        ],
        "hints": [
          {
            "class": "sbg:AWSInstanceType",
            "value": "c4.8xlarge"
          }
        ],
        "sbg:projectName": "CBTTC_0012a cell line",
        "sbg:revisionsInfo": [
          {
            "sbg:revision": 0,
            "sbg:modifiedBy": "gaonkark",
            "sbg:modifiedOn": 1557030198,
            "sbg:revisionNotes": "Copy of gaonkark/cnmc-test-space/samtools-bedcov/4"
          },
          {
            "sbg:revision": 1,
            "sbg:modifiedBy": "gaonkark",
            "sbg:modifiedOn": 1557088381,
            "sbg:revisionNotes": ""
          },
          {
            "sbg:revision": 2,
            "sbg:modifiedBy": "gaonkark",
            "sbg:modifiedOn": 1557093119,
            "sbg:revisionNotes": ""
          },
          {
            "sbg:revision": 3,
            "sbg:modifiedBy": "gaonkark",
            "sbg:modifiedOn": 1557093426,
            "sbg:revisionNotes": ""
          }
        ],
        "sbg:image_url": null,
        "sbg:appVersion": [
          "v1.0"
        ],
        "sbg:id": "gaonkark/cbttc-0012a-cell-line/samtools-bedcov-4/3",
        "sbg:revision": 3,
        "sbg:revisionNotes": "",
        "sbg:modifiedOn": 1557093426,
        "sbg:modifiedBy": "gaonkark",
        "sbg:createdOn": 1557030198,
        "sbg:createdBy": "gaonkark",
        "sbg:project": "gaonkark/cbttc-0012a-cell-line",
        "sbg:sbgMaintained": false,
        "sbg:validationErrors": [],
        "sbg:contributors": [
          "gaonkark"
        ],
        "sbg:latestRevision": 3,
        "sbg:publisher": "sbg",
        "sbg:content_hash": "aa8dfde1e63c5763fc45de2018b1d47c19a11b9a970dd93797acc4c33078801ac"
      },
      "label": "samtools_bedcov",
      "sbg:x": -145,
      "sbg:y": -5
    },
    {
      "id": "samtools_index_cram",
      "in": [
        {
          "id": "input",
          "source": "input"
        }
      ],
      "out": [
        {
          "id": "output"
        }
      ],
      "run": {
        "class": "CommandLineTool",
        "cwlVersion": "v1.0",
        "$namespaces": {
          "sbg": "https://sevenbridges.com"
        },
        "id": "gaonkark/cbttc-0012a-cell-line/samtools-index-cram/4",
        "baseCommand": [
          "samtools flagstat"
        ],
        "inputs": [
          {
            "id": "input",
            "type": "File",
            "inputBinding": {
              "position": 0
            }
          }
        ],
        "outputs": [
          {
            "id": "output",
            "type": "File?",
            "outputBinding": {
              "glob": "*.txt",
              "outputEval": "$(inheritMetadata(self, inputs.input))"
            },
            "secondaryFiles": [
              ".crai"
            ]
          }
        ],
        "label": "samtools_flagstat_cram",
        "arguments": [
          {
            "position": 3,
            "prefix": "",
            "shellQuote": false,
            "valueFrom": "${\n  var input_name = inputs.input\n  return \"> \"+input_name.path.split('/').pop().split('.')[0]+\".flagstat.txt\"\n}"
          }
        ],
        "requirements": [
          {
            "class": "ShellCommandRequirement"
          },
          {
            "class": "ResourceRequirement",
            "ramMin": 20
          },
          {
            "class": "DockerRequirement",
            "dockerPull": "quay.io/biocontainers/samtools:1.9--h8571acd_11"
          },
          {
            "class": "InlineJavascriptRequirement",
            "expressionLib": [
              "\nvar setMetadata = function(file, metadata) {\n    if (!('metadata' in file))\n        file['metadata'] = metadata;\n    else {\n        for (var key in metadata) {\n            file['metadata'][key] = metadata[key];\n        }\n    }\n    return file\n};\n\nvar inheritMetadata = function(o1, o2) {\n    var commonMetadata = {};\n    if (!Array.isArray(o2)) {\n        o2 = [o2]\n    }\n    for (var i = 0; i < o2.length; i++) {\n        var example = o2[i]['metadata'];\n        for (var key in example) {\n            if (i == 0)\n                commonMetadata[key] = example[key];\n            else {\n                if (!(commonMetadata[key] == example[key])) {\n                    delete commonMetadata[key]\n                }\n            }\n        }\n    }\n    if (!Array.isArray(o1)) {\n        o1 = setMetadata(o1, commonMetadata)\n    } else {\n        for (var i = 0; i < o1.length; i++) {\n            o1[i] = setMetadata(o1[i], commonMetadata)\n        }\n    }\n    return o1;\n};"
            ]
          }
        ],
        "hints": [
          {
            "class": "sbg:AWSInstanceType",
            "value": "c4.8xlarge"
          }
        ],
        "sbg:projectName": "CBTTC_0012a cell line",
        "sbg:revisionsInfo": [
          {
            "sbg:revision": 0,
            "sbg:modifiedBy": "gaonkark",
            "sbg:modifiedOn": 1557020337,
            "sbg:revisionNotes": null
          },
          {
            "sbg:revision": 1,
            "sbg:modifiedBy": "gaonkark",
            "sbg:modifiedOn": 1557020422,
            "sbg:revisionNotes": ""
          },
          {
            "sbg:revision": 2,
            "sbg:modifiedBy": "gaonkark",
            "sbg:modifiedOn": 1557028256,
            "sbg:revisionNotes": ""
          },
          {
            "sbg:revision": 3,
            "sbg:modifiedBy": "gaonkark",
            "sbg:modifiedOn": 1557028839,
            "sbg:revisionNotes": ""
          },
          {
            "sbg:revision": 4,
            "sbg:modifiedBy": "gaonkark",
            "sbg:modifiedOn": 1557094681,
            "sbg:revisionNotes": ""
          }
        ],
        "sbg:image_url": null,
        "sbg:appVersion": [
          "v1.0"
        ],
        "sbg:id": "gaonkark/cbttc-0012a-cell-line/samtools-index-cram/4",
        "sbg:revision": 4,
        "sbg:revisionNotes": "",
        "sbg:modifiedOn": 1557094681,
        "sbg:modifiedBy": "gaonkark",
        "sbg:createdOn": 1557020337,
        "sbg:createdBy": "gaonkark",
        "sbg:project": "gaonkark/cbttc-0012a-cell-line",
        "sbg:sbgMaintained": false,
        "sbg:validationErrors": [],
        "sbg:contributors": [
          "gaonkark"
        ],
        "sbg:latestRevision": 4,
        "sbg:publisher": "sbg",
        "sbg:content_hash": "aaabfb0d551729aa419472e5946aada338c0878215cf2d9bc5faac57b9b6841a9"
      },
      "label": "samtools_flagstat_cram",
      "sbg:x": -128,
      "sbg:y": 130
    }
  ],
  "requirements": [],
  "sbg:projectName": "CBTTC_0012a cell line",
  "sbg:revisionsInfo": [
    {
      "sbg:revision": 0,
      "sbg:modifiedBy": "gaonkark",
      "sbg:modifiedOn": 1557144921,
      "sbg:revisionNotes": null
    },
    {
      "sbg:revision": 1,
      "sbg:modifiedBy": "gaonkark",
      "sbg:modifiedOn": 1557145004,
      "sbg:revisionNotes": ""
    }
  ],
  "sbg:image_url": "https://cavatica.sbgenomics.com/ns/brood/images/gaonkark/cbttc-0012a-cell-line/bedcov-flagstaff/1.png",
  "sbg:appVersion": [
    "v1.0"
  ],
  "id": "https://cavatica-api.sbgenomics.com/v2/apps/gaonkark/cbttc-0012a-cell-line/bedcov-flagstaff/1/raw/",
  "sbg:id": "gaonkark/cbttc-0012a-cell-line/bedcov-flagstaff/1",
  "sbg:revision": 1,
  "sbg:revisionNotes": "",
  "sbg:modifiedOn": 1557145004,
  "sbg:modifiedBy": "gaonkark",
  "sbg:createdOn": 1557144921,
  "sbg:createdBy": "gaonkark",
  "sbg:project": "gaonkark/cbttc-0012a-cell-line",
  "sbg:sbgMaintained": false,
  "sbg:validationErrors": [],
  "sbg:contributors": [
    "gaonkark"
  ],
  "sbg:latestRevision": 1,
  "sbg:publisher": "sbg",
  "sbg:content_hash": "a2b2b0c9a7de609ce44c51f12a69f63d2f46cd0da889a60fd244b502a48945730"
}
