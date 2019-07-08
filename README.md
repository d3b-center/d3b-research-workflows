# d3b-research-workflows
Most Directories are submodules - tools developed as standalone aggregated in this repo.  To add a submodule:
```
git submodule add <git remote path>
git submodule init
git submodule update
# then commit with your current changes,or as it's on changes
```

fusion_prioritization:
      Requirement: folder structure from cookiecutter https://github.com/drivendata/cookiecutter-data-science
      Inputs: Downloaded manifest from cavatica project
      
      1) gather_fusion_sbg.R gather fusion calls from cavatica using R api for opendipg samples
      2) gather_rsem_sbg.R gather rsem files for opendipg samples
      3) merge_fusion_tsv_files.R merge fusion calls per caller and add sample_id and case_id
      4) merge_rsem_results_files.R merge rsem gene level TPM values into a matrix
      5) filtering_fusion_calls.R filter readthrough, GTEX-Recurrent annotated fusions
      6) filtering_exp_fusion_genes.R filter fusion calls if both genes are not expressed
      
      Output : DriverFusions.txt

## d3b_bic-seq2
CWL implementation of BIC-SEQ2 CNV pipeline.

## Linked-SV
CWL implementation of Linked-SV structural variant using long reads caller.

## Codex2
Whole exome BATCH CNV Caller

## Canvas
Illumina CNV caller, with exome capability

## Sanger Tools
CWL Implementation of CaVEMan snv caller and Pindel indel/sv caller