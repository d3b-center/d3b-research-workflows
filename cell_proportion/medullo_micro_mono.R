install.packages("BRETIGEA")
library(BRETIGEA)
library(knitr) #only for visualization
library(readr)
library(dplyr)
library(reshape2)
library(tidyr)
library(ggplot2)
library(ggpubr)

theme_Publication <- function(base_size=25, base_family="Arial") {
  library(grid)
  library(ggthemes)
  (theme_foundation(base_size=base_size, base_family=base_family)
    + theme(plot.title = element_text(face = "bold",
                                      size = rel(1.2), hjust = 0.5),
            text = element_text(family="Arial"),
            panel.background = element_rect(colour = NA),
            plot.background = element_rect(colour = NA),
            panel.border = element_rect(colour = NA),
            axis.title = element_text(face = "bold",size = rel(0.85)),
            axis.title.y = element_text(angle=90,vjust =2,size=rel(0.85)),
            axis.title.x = element_text(vjust = -0.2,size=rel(0.85)),
            axis.text = element_text(size=12,color="black",face="bold"), 
            axis.line = element_line(colour="black",size=0.7),
            axis.ticks = element_line(),
            panel.grid.major = element_line(colour="#f0f0f0"),
            panel.grid.minor = element_blank(),
            legend.key = element_rect(colour = NA),
            legend.position = "right",
            legend.direction = "vertical",
            legend.key.size= unit(0.8, "cm"),
            legend.margin = unit(0.9, "cm"),
            legend.title = element_text(face="italic"),
            plot.margin=unit(c(10,5,5,5),"mm"),
            strip.background=element_rect(colour="#f0f0f0",fill="#f0f0f0"),
            strip.text = element_text(face="bold")
    ))
  
}


#expression v12 ( same as v11 )
exp<-readRDS("~/Documents/OpenPBTA-analysis/data/pbta-gene-expression-rsem-fpkm-collapsed.stranded.rds")
#clinical v12
clinical<-read_tsv("~/Documents/OpenPBTA-analysis/data/pbta-histologies.tsv")
# xcell monoctype marker cells
gene_marker<-read_tsv("~/Downloads/13059_2017_1349_MOESM3_ESM.txt") 
monocyte_marker<-gene_marker[grep("Monocyte",gene_marker$Celltype_Source_ID),] %>% select(-c(`# of genes`,Celltype_Source_ID)) %>% as.data.frame() %>% t() 
monocyte_marker<-melt(monocyte_marker)
monocyte_marker<-unique(monocyte_marker$value)
monocyte_marker<-monocyte_marker[!is.na(monocyte_marker)]




# select medullo samples
clinical_medullo<-clinical %>% filter(experimental_strategy=="RNA-Seq" & disease_type_new=="Medulloblastoma")
exp<-exp[,which(colnames(exp) %in% clinical_medullo$Kids_First_Biospecimen_ID)]

# add monocyte/macrophage marker genes https://actaneurocomms.biomedcentral.com/articles/10.1186/s40478-019-0665-y
# plus marker genes for monocyte from xcell https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5688663/bin/13059_2017_1349_MOESM3_ESM.xlsx
# markers_df_brain<-rbind(markers_df_brain,data.frame("markers"=c("F10", "EMILIN2", "F5", "C3", "GDA", "MKI67", "SELL", "HP","FN1","ANXA2","CD24","S100A6","MGST1","SLPI"),"cell"=rep("mon",14)))

markers_df_brain<-rbind(markers_df_brain,data.frame("markers"=c("F10", "EMILIN2", "F5", "C3", "GDA", "MKI67", "SELL", "HP","FN1","ANXA2","CD24","S100A6","MGST1","SLPI",monocyte_marker),"cell"=rep("mon",317)))


# cell type proportions use all 1000 marker genes from mic and 317 from monocyte
cell_type_proportions = findCells(exp,markers = markers_df_brain, nMarker = 1000,method = "SVD")
cell_type_proportions<-melt(cell_type_proportions)

# add subtypes
cell_type_proportions<-cell_type_proportions %>% left_join(clinical_medullo ,by=c("Var1"="Kids_First_Biospecimen_ID"))
write.table(cell_type_proportions,"~/Documents/Dai/cell_proportions.tsv",sep="\t",quote = FALSE,row.names = FALSE)

# select mic mon
cell_type_proportions_micro_mono<-cell_type_proportions[which(cell_type_proportions$Var2 %in% c("mic","mon")),]

png("~/Documents/Dai/medullo_micro_mono.png",width = 1000,height = 1000)
ggplot(cell_type_proportions_micro_mono,aes(x=Var2,y=value,fill=tumor_descriptor))+geom_boxplot()+stat_compare_means()+facet_wrap(~molecular_subtype)+xlab("cell type")+ylab("proportions")+theme_Publication()
dev.off()

png("~/Documents/Dai/medullo_all_brain_cells.png",height = 1000)
ggplot(cell_type_proportions,aes(x=Var2,y=value))+geom_boxplot()+stat_compare_means()+facet_wrap(~molecular_subtype,nrow = 4)+xlab("cell type")+ylab("proportions")+theme_Publication()
dev.off()



write.table(markers_df_brain,"~/Documents/Dai/marker_df_brain.tsv",sep="\t",quote = FALSE,row.names = FALSE)

