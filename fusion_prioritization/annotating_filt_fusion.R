library("reshape2")
library("data.table")
library("plyr")
library(ggplot2)
library(dplyr)
library(RColorBrewer)
library(tidyr)

basePD<-"/mnt/isilon/cbmi/variome/gaonkark/RNAseq_fusion/cbttc_gather_rna_fusion/opendipg"

####### separate low expressing fusions and fusions where gene expression not reported
total<-read.delim(paste0(basePD,'/data/processed/Gene_Fusions_exp.txt'), stringsAsFactors = F)


head(total)

# annotate using COSMIC 
for.table <- total
cosmic <- read.csv(paste0(basePD,"/references/Cosmic_gene_census.csv"), stringsAsFactors = F)
genes.in.cosmic <- unlist(strsplit(cosmic$Synonyms, split = ","))
genes.in.cosmic <- unique(c(cosmic$Gene.Symbol, genes.in.cosmic))
for.table$Cosmic <- ifelse(for.table$Gene1 %in% genes.in.cosmic | for.table$Gene2 %in% genes.in.cosmic, 'Yes', 'No')
table(for.table$Cosmic)

# annotate using kinases
kinase <- read.delim(paste0(basePD,'/references/kinases.txt'),stringsAsFactors = F)
for.table$Kinase <- ifelse(for.table$Gene1 %in% kinase$gene_symbol | for.table$Gene2 %in% kinase$gene_symbol, 'Yes', 'No')
table(for.table$Kinase)

# annotate using transcription factors
tf <- read.delim(paste0(basePD,'/references/TRANSFAC_TF.txt'), header = F)
for.table$TF <- ifelse(for.table$Gene1 %in% tf$V1 | for.table$Gene2 %in% tf$V1, 'Yes', 'No')
head(for.table$TF)

# n = 284
for.table <- unique(for.table[which(for.table$Cosmic == "Yes" | for.table$Kinase == "Yes" | for.table$TF == "Yes"),])
#length(setdiff(drivers$Fused_Genes, for.table$Fused_Genes)) # 7 fusions are missing
for.table$Gene1 <- NULL
for.table$Gene2 <- NULL
nrow(for.table)

clin <- read.delim(paste0(basePD,'/references/CBTTC-broad-histologies\ -\ CBTTC-broad-hist.csv'), stringsAsFactors = F,sep=",")
clin<-clin[,c("sample","broad.histology","diagnosis")]
colnames(clin)<-c("Sample","Histology.Broad","Diagnosis")

#histology labels
hist.dt.ct <- unique(clin[,c('Histology.Broad','Sample')])
hist.dt.ct <- plyr::count(hist.dt.ct, 'Histology.Broad')
hist.dt.ct$freq <- paste0(hist.dt.ct$Histology.Broad,' (n=', hist.dt.ct$freq, ')')
colnames(hist.dt.ct)[2] <- 'Histology.Broad.Label'

to.add<-readRDS(paste0(basePD,"/data/interim/fusion_all_list.rds"))
colnames(to.add)[1]<-"Fused_Genes"


# excel tab 1
extab1 <- merge(total, to.add, by = c('Sample','Fused_Genes'))

extab1 <- merge(extab1, hist.dt.ct, by = 'Histology.Broad')
extab1 <- extab1[,c("Sample","Fused_Genes","Histology.Broad.Label","Caller","Fusion_Type")]
extab1 <- extab1[order(extab1$Fused_Genes, extab1$Sample),]
extab1$Cytogenetics <- "NA"
extab1 <- extab1[,c("Fused_Genes","Sample","Histology.Broad.Label","Caller","Fusion_Type","Cytogenetics")]


# excel tab 2
extab2 <- merge(for.table, hist.dt.ct, by = 'Histology.Broad')
extab2 <- extab2[,c("Sample","Fused_Genes","Histology.Broad.Label","Cosmic","TF","Kinase")]
extab2 <- extab2 %>% 
  group_by(Fused_Genes, Histology.Broad.Label, Cosmic, TF, Kinase) %>% 
  summarise(Sample = toString(Sample), Samples.Found.In = n()) %>% 
  unique() %>% as.data.frame()
extab2 <- unique(extab2[,c("Fused_Genes","Cosmic","TF","Kinase")])
extab1 <- merge(extab1, extab2, by = 'Fused_Genes', all.x = T)
extab1[is.na(extab1)] <- "No"
# 2755
nrow(extab1)
write.table(extab1, file = paste0(basePD,'/data/processed/Filtered_Annotated_Fusions.txt'), quote = F, sep = "\t", row.names = F)




#########
# plot for fusions only
#########
total$Gene1 <- NULL
total$Gene2 <- NULL


# histology detailed labels
hist.ct <- unique(clin[,c('Histology.Broad','Sample')])
hist.ct <- plyr::count(hist.ct, 'Histology.Broad')
hist.ct$freq <- paste0(hist.ct$Histology.Broad,' (n=', hist.ct$freq, ')')
colnames(hist.ct)[2] <- 'Histology.Broad.Label'

#final <- merge(total, clin[,c('Sample','Histology.Broad')], by = 'Sample') 
final<-total
head(final)


final <- merge(final, hist.ct, by= 'Histology.Broad')
final <- final %>% group_by(Sample,Histology.Broad) %>% summarise(value = n()) 
final <- final %>% group_by(Histology.Broad) %>% mutate(median = median(value)) %>% as.data.frame()
to.include <- setdiff(clin$Histology.Broad, final$Histology.Broad)
final <- rbind(final, data.frame(Sample = c(rep(NA,length(to.include))), 
                                 Histology.Broad = to.include, 
                                 value = c(rep(0,length(to.include))), 
                                 median = c(rep(0,length(to.include)))))
final$Histology.Broad <- reorder(final$Histology.Broad, final$median)
write.table(final, file = paste0(basePD,'/data/processed/FusionPlot_rawdata.txt'), quote = F, sep = "\t", row.names = F)


p <- ggplot(final, aes(x = Histology.Broad, y = value, color = Histology.Broad, alpha = 0.5)) + 
  geom_boxplot(outlier.shape = 21, fill = 'white') + 
  geom_jitter(position=position_jitter(width=.1, height=0), shape = 21) +
  stat_boxplot(geom ='errorbar', width = 0.5) +
  theme_bw() +
  guides(alpha = FALSE, fill = FALSE) + 
  xlab("Histology") + ylab('Number of Fusions') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1)) + 
  guides(color = F) +
  scale_y_continuous(breaks = seq(0, 26, by = 5))
p
ggsave(filename = paste0(basePD,'/reports/figures/FusionPlot.pdf'), plot = p, device = 'pdf', height = 6, width = 10)

medians <- unique(final[,c("Histology.Broad","median")])
write.table(medians, file = paste0(basePD,'/data/processed/FusionPlot_medians.txt'), quote = F, sep = "\t", row.names = F)

