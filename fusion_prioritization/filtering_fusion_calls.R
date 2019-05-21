library("reshape2")
library("data.table")
library("plyr")
library(ggplot2)
library(dplyr)
library(RColorBrewer)
library(tidyr)



basePD<-"/mnt/isilon/cbmi/variome/gaonkark/RNAseq_fusion/cbttc_gather_rna_fusion/opendipg"

# star fusion
sf <- data.table::fread(paste0(basePD,"/data/interim/star_fusion.tsv"), stringsAsFactors = F,sep="\t")
sf$LeftBreakpoint <- gsub('^chr','',sf$LeftBreakpoint)
sf$RightBreakpoint <- gsub('^chr','',sf$RightBreakpoint)
colnames(sf)[c(6,8)] <- c('Gene1_pos','Gene2_pos')
sf$Fusion_Type <- ifelse(sf$PROT_FUSION_TYPE == "INFRAME",'In-Frame','Other')
sf$Caller <- 'STARFusion'
sf$Sample <-sf$sample_id
sf$FusionName<-sf$X.FusionName
sf.total <- unique(sf[,c('FusionName','Sample','Caller','Fusion_Type')])



# arriba fusion
ar <- data.table::fread(paste0(basePD,"/data/interim/arriba_fusion.tsv"), stringsAsFactors = F,sep="\t")
ar$LeftBreakpoint <- gsub('^chr','',ar$breakpoint1)
ar$RightBreakpoint <- gsub('^chr','',ar$breakpoint2)
ar$Fusion_Type <- ifelse(ar$reading_fram == 'in-frame','In-Frame','Other')
ar$Caller <- 'arriba'
ar$Sample <-ar$sample_id
ar$FusionName <-paste0(gsub(",","/",ar$X.gene1),"--",gsub(",","/",ar$gene2))
ar.total <- unique(ar[,c('FusionName','Sample','Caller','Fusion_Type')])



#pizzly

#pz <- data.table::fread(paste0(basePD,"/data/interim/pizzly_fusion.tsv"), stringsAsFactors = F,sep="\t")
#pz$LeftBreakpoint <- gsub('^chr','',pz$breakpoint1)
#pz$RightBreakpoint <- gsub('^chr','',pz$breakpoint2)
#pz$Fusion_Type <- 'Unknown'
#pz$Caller <- 'pizzly'
#pz$Sample <-pz$sample_id
#pz$FusionName <-paste0(gsub(",","/",pz$geneA.name),"--",gsub(",","/",pz$geneB.name))
#pz.total <- unique(pz[,c('FusionName','Sample','Caller','Fusion_Type')])


sf.rt <- unique(sf[grep('readthrough|neighbors|GTEx_Recurrent',sf$annots),'FusionName'])
#https://arriba.readthedocs.io/en/latest/interpretation-of-results/#frequent-types-of-false-positives
#not filtered for pcr_fusions
ar.rt <- unique(ar[grep("read-through|non-canonical_splicing",ar$type),'FusionName'])
rts <- unique(c(sf.rt$FusionName, ar.rt$FusionName))
rts.rev <- unique(unlist(lapply(strsplit(rts, '--'), FUN = function(x) paste0(x[2],'--',x[1]))))
rts <- unique(c(rts, rts.rev))



#all.callers <- rbind(ar.total, sf.total, pz.total)
all.callers<-rbind(ar.total, sf.total)



#histology
clin<-read.delim("../../references/CBTTC-broad-histologies\ -\ CBTTC-broad-hist_sample.csv",stringsAsFactors = F,sep="\t")

clin<-unique(clin[,c("sample","diagnosis","short.histology","broad.histology","composition")])

head(clin)
head(all.callers)


#merge callers and clinical information
all.callers<-merge(all.callers, clin, by.x="Sample", by.y="sample")

all.callers <- unique(all.callers[,c('Sample','FusionName','Caller','Fusion_Type','broad.histology')])
colnames(all.callers)<-c("Sample","Fused_Genes","Caller","Fusion_Type","Histology.Broad")
final<-all.callers


#driver fusions from Literature Jo Lynne
lit.genes <- read.delim('../../references/driver-fusions-v2.txt', stringsAsFactors = F)
lit.genes <- lit.genes[!is.na(lit.genes$FusionPartner),]
head(all.callers)
for(i in 1:nrow(lit.genes)){
  genes.to.search <- lit.genes[i,2]
  fusions.to.search <- lit.genes[i,3]
  genes.to.search <- unlist(strsplit(genes.to.search, ','))
  genes.to.search <- c(paste0('^',genes.to.search,'-'), paste0('-',genes.to.search,'$'))
  if(fusions.to.search == ""){
    print("no fusions to check")
  } else {
    fusions.to.search <- paste0('^',fusions.to.search,'$')
    genes.to.search <- c(genes.to.search, fusions.to.search)
  }
  genes.to.search <- paste0(genes.to.search, collapse = '|')
  hist.to.search <- lit.genes[i,1]
  getfusions <- all.callers[grep(genes.to.search, all.callers$Fused_Genes),]
  getfusions <- getfusions[which(getfusions$Histology.Broad %in% hist.to.search),]
  getfusions <- unique(getfusions)
  if(nrow(getfusions) == 0){
    print(hist.to.search)
    print(genes.to.search)
  }
  if(i == 1){
    to.add <- getfusions
  } else {
    to.add <- rbind(to.add, getfusions)
  }
}
to.add <- unique(to.add)
colnames(to.add) <- colnames(all.callers)
print("Literature gene fusions")
to.add


# merge the three lists
final <- rbind(all.callers, to.add)
final <- unique(final)

# remove read-throughs
final <- final[-which(final$Fused_Genes %in% rts),]
saveRDS(final,paste0(basePD,"/data/interim/fusion_all_list.rds"))
all.callers<-final

# Gene fusion should be in-frame
# Called by at least 2 callers
all.callers.summary <- all.callers %>% 
  filter(Fusion_Type != "Other") %>%
  group_by(Fused_Genes, Sample, Histology.Broad ) %>% 
  unique() %>%
  mutate(Caller = toString(Caller), caller.count = n()) %>%
  filter(caller.count >= 2) %>% 
  select(-caller.count, -Caller, -Fusion_Type) %>%
  unique() %>%
  as.data.frame()

print("caller count")
head(all.callers.summary)


# or found in at least 2 samples of the same histology 
sample.count <- all.callers %>% 
  filter(Fusion_Type != "Other") %>%
  group_by(Fused_Genes, Histology.Broad) %>% 
  unique() %>%
  mutate(sample.count = n()) %>%
  filter(sample.count > 1) %>%
  select(-Caller, -sample.count, -Fusion_Type) %>%
  unique() %>%
  as.data.frame() 
length(unique(sample.count$Fused_Genes))

# or 3' or 5' gene recurrently fused within a histology (>= 5 genes)
rec <- cbind(all.callers, colsplit(all.callers$Fused_Genes, pattern = '--', names = c("GeneA","GeneB")))
rec2 <- rec %>% group_by(Histology.Broad) %>% 
  select(Histology.Broad,GeneA,GeneB) %>% 
  unique() %>% group_by(Histology.Broad, GeneA) %>% 
  summarise(GeneA.ct = n()) %>%
  filter(GeneA.ct >= 5) %>% as.data.frame()
rec3 <- rec %>% group_by(Histology.Broad) %>% 
  select(Histology.Broad,GeneA,GeneB) %>% 
  unique() %>% group_by(Histology.Broad, GeneB) %>% 
  summarise(GeneB.ct = n()) %>%
  filter(GeneB.ct >= 5) %>% as.data.frame()
rec2 <- merge(rec2, rec, by = c('GeneA','Histology.Broad'))
rec3 <- merge(rec3, rec, by = c('GeneB','Histology.Broad'))
rec2 <- unique(rec2[,c("Sample","Fused_Genes","Histology.Broad")])
rec3 <- unique(rec3[,c("Sample","Fused_Genes","Histology.Broad")])
res <- unique(rbind(rec2, rec3))

# merge these 
total <- unique(rbind(all.callers.summary, sample.count, res))
print("total number of calls")
nrow(total)

# remove fusions that are in > 1 histology 
hist.count <- total %>% 
  select(Fused_Genes, Histology.Broad) %>%
  unique() %>%
  group_by(Fused_Genes) %>%
  summarise(hist.count = n()) %>%
  filter(hist.count == 1)
total <- total[which(total$Fused_Genes %in% hist.count$Fused_Genes),]
length(unique(total$Fused_Genes))



total<-rbind(total,to.add[,c("Sample","Fused_Genes","Histology.Broad")])


#final<-aggregate(final$Caller, list(final$Fused_Genes,final$Sample,final$Fusion_Type,final$Histology.Broad), paste, collapse=",")

#colnames(final)<-c("Fused_Genes","Sample","Fusion_Type","Histology.Broad","Callers")

saveRDS(total,paste0(basePD,"/data/interim/fusion_all_list_filt.rds"))
