#install DNAcopy
#install.packages("BiocManager")
#BiocManager::install("DNAcopy")

args<-commandArgs(TRUE)
#*ratio.txt file from controlFreec 
cnv<-args[1]

name<-strsplit(cnv,"[.]")
#name

library(DNAcopy)
cn <- read.table(cnv,header=T)
#cn

#create a CNA.object
CNA.object <-CNA( genomdat = cn[,3], chrom = cn[,1], maploc = cn[,2], data.type = 'logratio')

#smoothing recommended
CNA.smoothed <- smooth.CNA(CNA.object)

#generates segmentation
segs <- segment(CNA.smoothed, verbose=0, min.width=2)

segs2 = segs$output

#add sample name ; needed for gistic calls not standard segmentation file format 
segs2[,7]<-rep(name[[1]][1],nrow(segs2))

#output file will be name.seg
out_file<-paste(name[[1]][1],"seg", sep=".")

#writing to working directory
write.table(cbind(segs2[,7],segs2[,2:6]), file=out_file, row.names=F, col.names=F, quote=F, sep="\t")

