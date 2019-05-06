library(ggplot2)
library(plotly)
library(ggforce)
args<-commandArgs(TRUE)
file_cov<-args[1]
file_flagstat<-args[2]

#read_cov<-read.delim("~/Downloads/33087dd9-5a3e-49a7-ade9-697b33ff9dfc_NF1_exon_chr.coverage.txt",stringsAsFactors = F, header=F)
#read_flagstat<- read.delim("~/Downloads/33087dd9-5a3e-49a7-ade9-697b33ff9dfc.flagstat.txt",stringsAsFactors = F,sep="\t", header = F) 
read_cov<-read.delim(file_cov,stringsAsFactors = F,sep="\t", header = F)
read_flagstat<-read.delim(file_flagstat,stringsAsFactors = F,sep="\t", header = F)

libsize<-gsub(" .*","",read_flagstat[1,])
read_cov$V4<-gsub(" exon.*","", read_cov$V4)
read_cov$V4<-gsub(" transcript_id ","", read_cov$V4)
read_cov$V5<-gsub(" exon_number ","", read_cov$V5)
read_cov$V5<-as.numeric(read_cov$V5)
read_cov$V7<-read_cov[,"V3"]-read_cov[,"V2"]
read_cov$V8<-libsize
read_cov$V9<-(as.numeric(libsize)/1000000)
read_cov$V10<-read_cov$V9/read_cov$V7
read_cov$V11<-gsub("_.*","",basename(file_cov))
colnames(read_cov)<-c("chr","start","stop","transcript","exon_number","coverage","length","libsize","scaling_factor","FPKM","Sample")

data<-read_cov
write.table(data,paste0(gsub("_.*","",basename(file_cov)),"_FPKM.txt"),sep="\t",quote=F,row.names = F)
