library("reshape2")
library("data.table")
library("plyr")
library("tximport")

basePD<-"/mnt/isilon/cbmi/variome/gaonkark/RNAseq_fusion/cbttc_gather_rna_fusion/opendipg"
manifest_opendipg<-read.delim("/mnt/isilon/cbmi/variome/gaonkark/RNAseq_fusion/cbttc_gather_rna_fusion/opendipg/references/1555682641885-manifest.csv",sep=",",stringsAsFactors = F, header = T)

#get fid for files in opendipg project
list_file_STAR_rsem<-manifest_opendipg[grep("genes.results.gz", manifest_opendipg$name),2]

files<-file.path(paste0(basePD,"/data/raw/STAR_rsem/",list_file_STAR_rsem))
names(files)<-list_file_STAR_rsem
txi.rsem <- tximport(files, type = "rsem", txIn = FALSE, txOut = FALSE,abundanceCol = "TPM")

saveRDS(txi.rsem,paste0(basePD,"/data/interim/txi_rsem_all.rds"))
