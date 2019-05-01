library("reshape2")
library("data.table")
library("plyr")

basePD<-"/mnt/isilon/cbmi/variome/gaonkark/RNAseq_fusion/cbttc_gather_rna_fusion/opendipg"
manifest_opendipg<-read.delim("/mnt/isilon/cbmi/variome/gaonkark/RNAseq_fusion/cbttc_gather_rna_fusion/opendipg/references/1555682641885-manifest.csv",sep=",",stringsAsFactors = F, header = T)

files_arriba<-list.files(path=paste0(basePD,"/data/raw/arriba"),pattern = ".arriba.fusions.tsv",full.names = T)
files_STAR<-list.files(path=paste0(basePD,"/data/raw/STAR"),pattern = "STAR.fusion_predictions.abridged.coding_effect.tsv",full.names = T)
files_pizzly<-list.files(path=paste0(basePD,"/data/raw/pizzly"),pattern = ".pizzly.flattened.tsv",full.names = T)


read_file_add_names<-function(x,y,z){
df<-read.delim(x,header=T, stringsAsFactors = F,sep="\t")
df$sample_id<-rep(y,nrow(df)) 
df$case_id<-rep(z,nrow(df))
return(df)
}

merge_df<<-function(x,y){
df <- ldply(x, data.frame)
saveRDS(df,paste0(basePD,"/data/interim/",y,".RDS"))
write.table(df,paste0(basePD,"/data/interim/",y,".tsv"),sep="\t",quote=F, row.names=F)
}

#get files as list
import_arriba.list <- lapply(files_arriba,function(x) read_file_add_names(x,manifest_opendipg[grep(basename(x),manifest_opendipg$name),"sample_id"],manifest_opendipg[grep(basename(x),manifest_opendipg$name),"case_id"]))
import_STAR.list <- lapply(files_STAR,function(x) read_file_add_names(x,manifest_opendipg[grep(basename(x),manifest_opendipg$name),"sample_id"],manifest_opendipg[grep(basename(x),manifest_opendipg$name),"case_id"]))
import_pizzly.list <- lapply(files_pizzly,function(x) read_file_add_names(x,manifest_opendipg[grep(basename(x),manifest_opendipg$name),"sample_id"],manifest_opendipg[grep(basename(x),manifest_opendipg$name),"case_id"]))

#merge as dataframe
merge_df(import_arriba.list,"arriba_fusion")
merge_df(import_STAR.list,"STAR_fusion")
merge_df(import_pizzly.list,"pizzly_fusion")
