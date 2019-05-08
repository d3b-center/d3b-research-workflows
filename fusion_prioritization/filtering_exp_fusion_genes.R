library("reshape2")
library("data.table")
library("plyr")

basePD<-"/mnt/isilon/cbmi/variome/gaonkark/RNAseq_fusion/cbttc_gather_rna_fusion/opendipg"

####### separate low expressing fusions and fusions where gene expression not reported
final<-readRDS(paste0(basePD,"/data/interim/fusion_all_list_filt.rds"))
#get Rdata for opendipg
tximport_genes<-readRDS(paste0(basePD,"/data/interim/txi_rsem_all.rds"))
rna.mat<-tximport_genes$abundance
rna.mat<-as.data.frame(rna.mat)
rna.mat$gene_short_name<-unlist(lapply(rownames(rna.mat),function(x) strsplit(as.character(x),"_")[[1]][2]))


####### separate low expressing fusions and fusions where gene expression not reported
rna.mat$not_expressed <- apply(rna.mat[,2:ncol(rna.mat)], 1, FUN = function(x) all(x < 1))
df <- final
df <- cbind(colsplit(df$Fused_Genes, pattern = '--', names = c("Gene1","Gene2")), df)
genes <- unique(c(df$Gene1, df$Gene2))
to.check <- setdiff(genes, rna.mat$gene_short_name) # 90
rna.mat <- rna.mat[which(rna.mat$gene_short_name %in% genes),]
rna.mat <- melt(rna.mat)

metadata<-read.delim("../../references/1555682641885-manifest.csv",stringsAsFactors = F,sep=",")
rna.mat<-merge(rna.mat, metadata, by.x="variable",by.y="name")

clin<-read.delim("../../references/CBTTC-broad-histologies\ -\ CBTTC-broad-hist.csv",stringsAsFactors = F,sep=",")
clin<-unique(clin[,c("sample","broad.histology")])
clin$sample<-gsub("_.*","",clin$sample)
colnames(clin)<-c("Sample","Histology.Broad")

head(rna.mat)
head(clin)
rna.mat <- merge(rna.mat, clin[,c("Sample","Histology.Broad")], by.x = 'sample_id', by.y = "Sample")
rna.mat$Histology.Broad <- as.character(rna.mat$Histology.Broad)
head(rna.mat)


# now add filter
df$Gene1_model <- NA
df$Gene1_hist_mean <- NA
df$Gene1_mean <- NA
df$Gene1_expr <- NA
df$Gene2_model <- NA
df$Gene2_hist_mean <- NA
df$Gene2_mean <- NA
df$Gene2_expr <- NA
df$Gene1_not_expressed <- NA
df$Gene2_not_expressed <- NA
for(i in 1:nrow(df)){
  print(i)
  genea <- df[i,'Gene1']
  geneb <- df[i,'Gene2']
  model <- df[i,'Model']
  hist <- df[i,'Histology.Broad']
  hist <- gsub(' [(].*','', hist)
  genea.expr <- unique(rna.mat[which(rna.mat$gene_short_name == genea),'not_expressed'])
  geneb.expr <- unique(rna.mat[which(rna.mat$gene_short_name == geneb),'not_expressed'])
  genea.val <- rna.mat[which(rna.mat$variable %in% model & rna.mat$gene_short_name == genea),'value']
  geneb.val <- rna.mat[which(rna.mat$variable %in% model & rna.mat$gene_short_name == geneb),'value']
  genea.hist.mean <- mean(rna.mat[which(rna.mat$gene_short_name == genea & rna.mat$Histology.Broad == hist),'value'])
  geneb.hist.mean <- mean(rna.mat[which(rna.mat$gene_short_name == geneb & rna.mat$Histology.Broad == hist),'value'])
  genea.mean <- mean(rna.mat[which(rna.mat$gene_short_name == genea),'value'])
  geneb.mean <- mean(rna.mat[which(rna.mat$gene_short_name == geneb),'value'])
  df[i,'Gene1_not_expressed'] <- ifelse(length(genea.expr) == 0, NA, genea.expr)
  df[i,'Gene1_model'] <- ifelse(is.na(genea.val) || length(genea.val) == 0, NA, genea.val)
  df[i,'Gene1_hist_mean'] <- ifelse(is.na(genea.hist.mean) || length(genea.hist.mean) == 0, NA, genea.hist.mean)
  df[i,'Gene1_mean'] <- ifelse(is.na(genea.mean) || length(genea.mean) == 0, NA, genea.mean)
  df[i,'Gene1_expr'] <- ifelse(df[i,'Gene1_model'] < df[i,'Gene1_mean'],'Decreased',ifelse(df[i,'Gene1_model'] == df[i,'Gene1_mean'], 'Same','Increased'))
  df[i,'Gene2_not_expressed'] <- ifelse(length(geneb.expr) == 0, NA, geneb.expr)
  df[i,'Gene2_model'] <- ifelse(is.na(geneb.val) || length(geneb.val) == 0, NA, geneb.val)
  df[i,'Gene2_hist_mean'] <- ifelse(is.na(geneb.hist.mean) || length(geneb.hist.mean) == 0, NA, geneb.hist.mean)
  df[i,'Gene2_mean'] <- ifelse(is.na(geneb.mean) || length(geneb.mean) == 0, NA, geneb.mean)
  df[i,'Gene2_expr'] <- ifelse(df[i,'Gene2_model'] < df[i,'Gene2_mean'],'Decreased',ifelse(df[i,'Gene2_model'] == df[i,'Gene2_mean'], 'Same','Increased'))
}
df[is.na(df)] <- NA
df$Gene1_not_expressed[is.na(df$Gene1_not_expressed)] <- "Not Reported"
df$Gene2_not_expressed[is.na(df$Gene2_not_expressed)] <- "Not Reported"
write.table(df, file = paste0(basePD,'/data/processed/Gene_Fusions_exp.txt'), quote = F, sep = "\t", row.names = F)

separate.fusions <- df[(df$Gene1_not_expressed %in% c(TRUE,"Not Reported") & df$Gene2_not_expressed %in% c(TRUE,"Not Reported")),]
if(nrow(separate.fusions) > 0){
  print("Fusions to be separated")
  write.table(separate.fusions, file = paste0(basePD,'/data/processed/Driver_Fusions_noExprReported.txt'), quote = F, sep = "\t", row.names = F)
  df <- df[-which(df$Fused_Genes %in% separate.fusions$Fused_Genes),]
}
final <- final[which(final$Fused_Genes %in% df$Fused_Genes),]
####### separate low expressing fusions and fusions where gene expression not reported 

write.table(final, file = paste0(basePD,'/data/processed/Driver_Fusions.txt'), quote = F, sep = "\t", row.names = F)




