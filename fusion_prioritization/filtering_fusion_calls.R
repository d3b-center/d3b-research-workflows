library("reshape2")
library("data.table")
library("plyr")

basePD<-"/mnt/isilon/cbmi/variome/gaonkark/RNAseq_fusion/cbttc_gather_rna_fusion/opendipg"

# star fusion
sf <- data.table::fread(paste0(basePD,"/data/interim/STAR_fusion.tsv"), stringsAsFactors = F,sep="\t")
sf$LeftBreakpoint <- gsub('^chr','',sf$LeftBreakpoint)
sf$RightBreakpoint <- gsub('^chr','',sf$RightBreakpoint)
colnames(sf)[c(6,8)] <- c('Gene1_pos','Gene2_pos')
sf$Fusion_Type <- ifelse(sf$PROT_FUSION_TYPE == "INFRAME",'In-Frame','Other')
sf$Caller <- 'STARFusion'
sf$Sample <-sf$sample_id
sf$FusionName<-sf$X.FusionName
sf.total <- unique(sf[,c('FusionName','Sample','Caller','Fusion_Type')])


head(sf.total)

# arriba fusion
ar <- data.table::fread(paste0(basePD,"/data/interim/arriba_fusion.tsv"), stringsAsFactors = F,sep="\t")
ar$LeftBreakpoint <- gsub('^chr','',ar$breakpoint1)
ar$RightBreakpoint <- gsub('^chr','',ar$breakpoint2)
ar$Fusion_Type <- ifelse(ar$reading_fram == 'in-frame','In-Frame','Other')
ar$Caller <- 'arriba'
ar$Sample <-ar$sample_id
ar$FusionName <-paste0(gsub(",","/",ar$X.gene1),"--",gsub(",","/",ar$gene2))
ar.total <- unique(ar[,c('FusionName','Sample','Caller','Fusion_Type')])

head(ar.total)

#pizzly

pz <- data.table::fread(paste0(basePD,"/data/interim/pizzly_fusion.tsv"), stringsAsFactors = F,sep="\t")
pz$LeftBreakpoint <- gsub('^chr','',pz$breakpoint1)
pz$RightBreakpoint <- gsub('^chr','',pz$breakpoint2)
pz$Fusion_Type <- 'Unknown'
pz$Caller <- 'pizzly'
pz$Sample <-pz$sample_id
pz$FusionName <-paste0(gsub(",","/",pz$geneA.name),"--",gsub(",","/",pz$geneB.name))
pz.total <- unique(pz[,c('FusionName','Sample','Caller','Fusion_Type')])

head(pz.total)

sf.rt <- unique(sf[grep('readthrough|neighbors|GTEx_Recurrent',sf$annots),'FusionName'])
#https://arriba.readthedocs.io/en/latest/interpretation-of-results/#frequent-types-of-false-positives
#not filtered for pcr_fusions
ar.rt <- unique(ar[grep("read-through|non-canonical_splicing",ar$type),'FusionName'])
rts <- unique(c(sf.rt$FusionName, ar.rt$FusionName))
rts.rev <- unique(unlist(lapply(strsplit(rts, '--'), FUN = function(x) paste0(x[2],'--',x[1]))))
rts <- unique(c(rts, rts.rev))

all.callers <- rbind(ar.total, sf.total, pz.total)

# remove read-throughs
final <- all.callers[-which(all.callers$FusionName %in% rts),]
saveRDS(final,paste0(basePD,"/data/interim/fusion_all_list.rds"))


####### separate low expressing fusions and fusions where gene expression not reported
final<-readRDS(paste0(basePD,"/data/interim/fusion_all_list.rds"))
#get Rdata for opendipg
tximport_genes<-readRDS(paste0(basePD,"/data/interim/txi_rsem_all.rds"))
rna.exp<-tximport_genes$abundance
rna_exp_df<-as.data.frame(rna.exp)
rna_exp_df$gene_short_name<-unlist(lapply(rownames(rna_exp_df),function(x) strsplit(as.character(x),"_")[[1]][2]))
rna_exp_df$not_expressed <- apply(rna_exp_df, 1, FUN = function(x) all(x < 1))

df <- final
df <- cbind(colsplit(df$FusionName, pattern = '--', names = c("Gene1","Gene2")), df)
genes <- unique(c(df$Gene1, df$Gene2))
genes<-c(genes[-grep("/", genes)],unique(unlist(lapply(genes[grep("/", genes)],function(x) strsplit(x,"/")[[1]][1])),unlist(lapply(genes[grep("/", genes)],function(x) strsplit(x,"/")[[1]][2]))))
genes<-c(genes[-grep("\\(", genes)], unlist(lapply(genes[grep("\\(", genes)],function(x) gsub("\\(.*\\)", "", x))))
genes<-unique(genes)
to.check <- setdiff(genes, rna_exp_df$gene_short_name) # 9
rna_exp_df <- rna_exp_df[which(rna_exp_df$gene_short_name %in% genes),]
rna_exp_df <- melt(rna_exp_df)


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
  genea.expr <- unique(rna_exp_df[which(rna_exp_df$gene_short_name == genea),'not_expressed'])
  geneb.expr <- unique(rna_exp_df[which(rna_exp_df$gene_short_name == geneb),'not_expressed'])
  genea.val <- rna_exp_df[which(rna_exp_df$variable %in% model & rna_exp_df$gene_short_name == genea),'value']
  geneb.val <- rna_exp_df[which(rna_exp_df$variable %in% model & rna_exp_df$gene_short_name == geneb),'value']
  genea.hist.mean <- mean(rna_exp_df[which(rna_exp_df$gene_short_name == genea & rna_exp_df$Histology.Broad == hist),'value'])
  geneb.hist.mean <- mean(rna_exp_df[which(rna_exp_df$gene_short_name == geneb & rna_exp_df$Histology.Broad == hist),'value'])
  genea.mean <- mean(rna_exp_df[which(rna_exp_df$gene_short_name == genea),'value'])
  geneb.mean <- mean(rna_exp_df[which(rna_exp_df$gene_short_name == geneb),'value'])
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
separate.fusions <- df[(df$Gene1_not_expressed %in% c(TRUE,"Not Reported") & df$Gene2_not_expressed %in% c(TRUE,"Not Reported")),]
if(nrow(separate.fusions) > 0){
  print("Fusions to be separated")
  write.table(separate.fusions, file = paste0(basePD,'/data/processed/Driver_Fusions_noExprReported.txt'), quote = F, sep = "\t", row.names = F)
  df <- df[-which(df$FusionName %in% separate.fusions$FusionName),]
}

final <- final[which(final$FusionName %in% df$FusionName),]
head(final)

####### separate low expressing fusions and fusions where gene expression not reported

#driver-fusions
driver.fusions <- final[,c("FusionName","Sample","Caller","Fusion_type")]
driver.fusions <- driver.fusions[-which(driver.fusions$FusionName %in% c("SRP9_EPHX1")),]
colnames(driver.fusions) <- c("Fused_Genes","Sample","Method","Fusion_Type")
write.table(driver.fusions, file = paste0(basePD,'data/processed/DriverFusions.txt'), quote = F, sep = "\t", row.names = F)



