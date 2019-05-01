#library("remotes")
#install_github("sbg/sevenbridges-r")

library("sevenbridges")
library("tidyr")


basePD<-"/mnt/isilon/cbmi/variome/gaonkark/RNAseq_fusion/cbttc_gather_rna_fusion/opendipg/"
#download manifest from opendipg project
manifest_opendipg<-read.delim("/mnt/isilon/cbmi/variome/gaonkark/RNAseq_fusion/cbttc_gather_rna_fusion/opendipg/references/1555682641885-manifest.csv",sep=",",stringsAsFactors = F, header = T)	

#vi ~/.Renviron
#SBG_TOKEN=my_sbgtoken

sbgtoken<-Sys.getenv("SBG_TOKEN")

############to download required files##############
(a <- Auth(platform = "cavatica", token = sbgtoken))
a$user(username = "gaonkark")

#get fid for files in opendipg project
list_fid_STAR_rsem<-manifest_opendipg[grep("results.gz", manifest_opendipg$name),1]

#to download files
lapply(list_fid_STAR_rsem, function (x) a$project(id="kfdrc-harmonization/sd-bhjxbdqk-06")$file(id = as.character(x))$download("/mnt/isilon/cbmi/variome/gaonkark/RNAseq_fusion/cbttc_gather_rna_fusion/opendipg/data/raw/STAR_rsem"))


