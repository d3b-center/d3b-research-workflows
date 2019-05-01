args<-commandArgs(TRUE)
cnv<-args[1]

name<-strsplit(cnv,"[.]")
name

library(DNAcopy)
cn <- read.table(cnv,header=T)
cn

CNA.object <-CNA( genomdat = cn[,3], chrom = cn[,1], maploc = cn[,2], data.type = 'logratio')

CNA.smoothed <- smooth.CNA(CNA.object)

segs <- segment(CNA.smoothed, verbose=0, min.width=2)

segs2 = segs$output

segs2[,7]<-rep(name[[1]][1],nrow(segs2))

out_file<-paste(cnv,"seg", sep=".")

write.table(cbind(segs2[,7],segs2[,2:6]), file=out_file, row.names=F, col.names=F, quote=F, sep="\t")

