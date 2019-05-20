# d3b-research-workflows

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

