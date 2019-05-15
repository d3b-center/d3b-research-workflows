chris_jones_bam<-read.delim("~/Downloads/1557780400495-manifest.csv",sep=",",stringsAsFactors = F)

#pre-processing metadata
chris_jones_bam$sample_id<-sub("EGAR00001*[[:digit:]][[:digit:]][[:digit:]][[:digit:]][[:digit:]][[:digit:]]_","",chris_jones_bam$name)
chris_jones_bam$sample_id<-gsub("[.]bam","",chris_jones_bam$sample_id)
chris_jones_bam$sample_id<-gsub("[.]b","_N",chris_jones_bam$sample_id)
chris_jones_bam$sample_id<-gsub("[.]t","_T",chris_jones_bam$sample_id)
chris_jones_bam[grep("_N$", chris_jones_bam$sample_id),5]<-"Normal"
chris_jones_bam[grep("_T$", chris_jones_bam$sample_id),5]<-"Tumor"
colnames(chris_jones_bam)[5]<-"sample_type"
chris_jones_bam$case_id<-sub("_[[:alpha:]]$","",chris_jones_bam$sample_id)



###############EGAD00001003762##############
get_ega<-read.delim("/Users/gaonkark/Downloads/EGAD00001003762/delimited_maps/Run_Sample_meta_info.map",header=FALSE,sep=";",stringsAsFactors = F)
s_tumor<-get_ega[-grep("normal", s[,5]),]
colnames(s_tumor)<-c("age","diagnosis","disease_site","grade","gender","location","meta_id","phenotype","subject_id","ENA")
s_normal<-s[grep("normal", s[,5]),]
colnames(s_normal)<-c("age","disease_site","gender","meta_id","phenotype","subject_id","ENA")
s_normal$diagnosis<-"NA"
s_normal$grade<-"NA"
s_normal$location<-s_normal$disease_site
s_V2<-rbind(s_tumor,s_normal[,-c(8,9)])
s_V2<-apply(s_V2,2,function(x) gsub(".*=","",x))[,1:9]

#download ICR_G101 errored out so files missing

chris_jones_bam_meta<-unique(merge(s_V2,chris_jones_bam,by.x='subject_id',by.y='case_id'))
chris_jones_bam_meta_normal<-chris_jones_bam_meta[which(chris_jones_bam_meta$sample_type=="Normal" & chris_jones_bam_meta$phenotype=="normal"),]
chris_jones_bam_meta_tumor<-chris_jones_bam_meta[which(chris_jones_bam_meta$sample_type!="Normal" & chris_jones_bam_meta$phenotype!="normal"),]
chris_jones_bam_meta<-rbind(chris_jones_bam_meta_normal,chris_jones_bam_meta_tumor)
mmc2<-read.delim("~/Downloads/mmc2.csv",stringsAsFactors = F, header = T, comment.char = "#", sep=",")
colnames(mmc2)<-mmc2[1,]
mmc2<-mmc2[-1,]
colnames(chris_jones_bam_meta)<-c("case_id","age_at_diagnosis","disease_type","primary_site","grade","gender","location","originalname","phenotype","id","name","project","sample_id","sample_type")
chris_jones_bam_meta<-cbind(chris_jones_bam_meta[,c("case_id","name","sample_id")],mmc2[unlist(lapply(chris_jones_bam_meta$originalname, function(x) grep(x,mmc2$Index_ID))),1:9])
chris_jones_bam_meta$name<-paste("https://s3.console.aws.amazon.com/s3/buckets/opendipg/pHGG/",chris_jones_bam_meta$name,sep="")
write.csv(chris_jones_bam_meta,"~/Documents/CNMC/all_CJ_EGAD00001003762.csv",quote = F,row.names = F)
###############End of EGAD00001003762##############


###############EGAD00001000706##############
#after EGAD00001003762
chris_jones_bam_v2<-chris_jones_bam[!chris_jones_bam$name %in% chris_jones_bam_meta$name,]
get_ega<-read.delim("/Users/gaonkark/Downloads/EGA_datasets/EGAD00001000706/delimited_maps/Run_Sample_meta_info.map",header=F,sep=";", stringsAsFactors = F)
#incorrect age
#case_id          gender         primary_site           sample_type location              age_at_diagnosis
# HSJD_DIPG_007   male  Low grade astrocytoma           pons diseased tissue              6.5     
# HSJD_DIPG_008   male           Glioblastoma           pons diseased tissue              9.9   
                      
s_tumor<-get_ega[-grep("normal", s[,5]),]
colnames(s_tumor)<-c("subject_id","gender","phenotype","disease_site","sample_type","age_at_diagnosis","grade","ENA")
s_normal<-get_ega[grep("normal", s[,5]),]
colnames(s_normal)<-c("subject_id","gender","phenotype","disease_site","sample_type","age_at_diagnosis","grade","ENA")

s_V2<-rbind(s_tumor,s_normal) 
s_V2<-apply(s_V2,2,function(x) gsub(".*=","",x))
s_V2<-as.data.frame(s_V2)
chris_jones_bam_meta<-unique(merge(s_V2,chris_jones_bam_v2,by.x='subject_id',by.y='case_id'))
chris_jones_bam_meta_normal<-chris_jones_bam_meta[which(chris_jones_bam_meta$sample_type.y=="Normal" & chris_jones_bam_meta$sample_type.x=="blood"),]
chris_jones_bam_meta_tumor<-chris_jones_bam_meta[which(chris_jones_bam_meta$sample_type.y!="Normal" & chris_jones_bam_meta$sample_type.x!="blood"),]
chris_jones_bam_meta<-rbind(chris_jones_bam_meta_normal,chris_jones_bam_meta_tumor)
colnames(chris_jones_bam_meta)<-c("case_id","gender","primary_site","sample_type_v1","location","age_at_diagnosis","grade","ENA","NA","id","name","project","sample_id","sample_type")
chris_jones_bam_meta$case_id<- gsub("HSJD_DIPG","HSJD_DIPG_",chris_jones_bam_meta$case_id)

chris_jones_bam_meta<-cbind(chris_jones_bam_meta[,c("case_id","name","sample_id")],mmc2[unlist(lapply(chris_jones_bam_meta$case_id, function(x) grep(x,mmc2$PMID_alias))),1:9])
chris_jones_bam_meta$name<-paste("https://s3.console.aws.amazon.com/s3/buckets/opendipg/pHGG/",chris_jones_bam_meta$name,sep="")
write.csv(chris_jones_bam_meta,"~/Documents/CNMC/all_CJ_EGAD00001000706.csv",quote = F,row.names = F)
###############End of EGAD00001000706##############

###############EGAD00001000705##############
get_ega<-read.delim("/Users/gaonkark/Downloads/EGAD00001000705/delimited_maps/Run_Sample_meta_info.map",header=F,sep=";", stringsAsFactors = F)
colnames(get_ega)<-c("subject_id","gender","phenotype","disease_site","sample_type","age_at_diagnosis","grade","ENA")
s_V2<-apply(get_ega,2,function(x) gsub(".*=","",x))[,1:6]

#from https://media.nature.com/original/nature-assets/ng/journal/v46/n5/extref/ng.2925-S1.pdf
get_match<-read.delim("/Users/gaonkark/Downloads/pedcbio_open_dipg_upload/phgg_cj_wgs_opendipg/sample_match",header=F)

#to match the sampleIDs
chris_jones_bam[grep("NCHP_DIPG6$", chris_jones_bam$case_id),"case_id"]<-c("NCHP_DIPG006" ,"NCHP_DIPG006")
chris_jones_bam[grep("NCHP_DIPG11$", chris_jones_bam$case_id),"case_id"]<-c("NCHP_DIPG011" ,"NCHP_DIPG011")
chris_jones_bam[grep("NCHP_DIPG52$", chris_jones_bam$case_id),"case_id"]<-c("NCHP_DIPG052" ,"NCHP_DIPG052")
chris_jones_bam[grep("NCHP_DIPG61$", chris_jones_bam$case_id),"case_id"]<-c("NCHP_DIPG061" ,"NCHP_DIPG061")
chris_jones_bam[grep("NCHP_DIPG65$", chris_jones_bam$case_id),"case_id"]<-c("NCHP_DIPG065" ,"NCHP_DIPG065")
chris_jones_bam[grep("NCHP_DIPG81$", chris_jones_bam$case_id),"case_id"]<-c("NCHP_DIPG081" ,"NCHP_DIPG081")
s_V2<-merge(s_V2,get_match,by.y="V2",by.x="subject_id")


chris_jones_bam_meta<-merge(chris_jones_bam,s_V2,by.x="case_id",by.y="V1")
chris_jones_bam_meta_normal<-chris_jones_bam_meta[which(chris_jones_bam_meta$sample_type.x=="Normal" & chris_jones_bam_meta$sample_type.y=="blood"),]
chris_jones_bam_meta_tumor<-chris_jones_bam_meta[which(chris_jones_bam_meta$sample_type.x!="Normal" & chris_jones_bam_meta$sample_type.y!="blood"),]
chris_jones_bam_meta<-rbind(chris_jones_bam_meta_normal,chris_jones_bam_meta_tumor)
colnames(chris_jones_bam_meta)<-c("case_id","id","name","project","sample_id","sample_type","originalname","gender","disease_type","NA","primary_site","age_at_diagnosis","NA")

chris_jones_bam_meta_RUSL<-chris_jones_bam_meta[grep("RUSL", chris_jones_bam_meta$originalname),]
chris_jones_bam_meta<-cbind(chris_jones_bam_meta[-grep("RUSL", chris_jones_bam_meta$originalname),c("case_id","name","sample_id")],mmc2[unlist(lapply(chris_jones_bam_meta$originalname, function(x) grep(x,mmc2$PMID_alias))),1:9])
#pHGG_META_0274 is NCHP_DIPG081 originalname=RUSL; has same age/survival/gender in ega to paper mentioned above; but not in mmc2 manifest?
chris_jones_bam_meta_RUSL<-data.frame(chris_jones_bam_meta_RUSL[,c(1,3,5)],'Index_ID'="NA",'Diagnosis'="Diffuse intrinsic pontine glioma","WHO_2007_Grade"="4","Location_group"="Brainstem","Location_specific"="Pons","Gender"="Male","Age_at_diagnosis_years"="6.7","Survival_time_months"="16.8")
chris_jones_bam_meta_RUSL$'Alive(0)_Dead(1)'<-"NA"

chris_jones_bam_meta<-rbind(chris_jones_bam_meta,chris_jones_bam_meta_RUSL)

chris_jones_bam_meta$name<-paste("https://s3.console.aws.amazon.com/s3/buckets/opendipg/pHGG/",chris_jones_bam_meta$name,sep="")
write.csv(chris_jones_bam_meta,"~/Documents/CNMC/all_CJ_EGAD00001000705.csv",quote = F,row.names = F)
###############End of EGAD00001000705##############



##############EMTAB_5528_450K#####################
targets_EMTAB_5528_450K <- read.csv("~/Desktop/E-MTAB-5528.sdrf.txt", as.is=TRUE,sep="\t",header = TRUE,stringsAsFactors = FALSE)
merged_targets_EMTAB_5528_450K<-merge(targets_EMTAB_5528_450K, mmc2,by.x="Source.Name",by.y="Index_ID")
merged_targets_EMTAB_5528_450K<-cbind(merged_targets_EMTAB_5528_450K[,c("Source.Name","Array.Data.File")],merged_targets_EMTAB_5528_450K[,31:38])
colnames(merged_targets_EMTAB_5528_450K)[1:2]<-c("case_id","name")
merged_targets_EMTAB_5528_450K$sample_id<-gsub("[.]idat","",merged_targets_EMTAB_5528_450K$name)
merged_targets_EMTAB_5528_450K$name<-paste("https://s3.console.aws.amazon.com/s3/buckets/opendipg/pHGG/",merged_targets_EMTAB_5528_450K$name,sep="")
merged_targets_EMTAB_5528_450K$Index_ID<-merged_targets_EMTAB_5528_450K$case_id
colnames(merged_targets_EMTAB_5528_450K)<-c("case_id","name","Diagnosis","WHO_2007_Grade","Location_group","Location_specific","Gender","Age_at_diagnosis_years","Survival_time_months","Alive(0)_Dead(1)","sample_id","Index_ID")
write.csv(merged_targets_EMTAB_5528_450K,"~/Documents/CNMC/all_CJ_EMTAB_5528_450K.csv",quote = F,row.names = F)
##############end of EMTAB_5528_450K#####################


############## ETABM_857 #####################
read.ArrayExpress_manifest<-read.delim("~/Downloads/E-TABM-857.sdrf.txt",sep="\t",header=T)
combined_bac32<-read.ArrayExpress_manifest

upload_bac32_manifest<-cbind(as.character(combined_bac32$id),as.character(combined_bac32$Array.Data.File),as.character(combined_bac32$project),as.character(combined_bac32$Characteristics..Sex.),as.character(combined_bac32$Characteristics..DiseaseState.),as.character(combined_bac32$Factor.Value..Age.),as.character(combined_bac32$Characteristics..OrganismPart.),as.character(combined_bac32$Labeled.Extract.Name))
upload_bac32_manifest<-as.data.frame(upload_bac32_manifest)
upload_bac32_manifest$sample_id<-unlist(lapply(combined_bac32$Array.Data.File,function(x) strsplit(as.character(x),"[.]")[[1]][1]))
colnames(upload_bac32_manifest)<-c("name","gender","disease_type","age_at_diagnosis","primary_site","orignalname","sample_id")
upload_bac32_manifest$age_at_diagnosis<-round(as.numeric(as.character(upload_bac32_manifest$age_at_diagnosis))/12,1)
upload_bac32_manifest$originalname<-gsub("_Cy5","",gsub(".*_R","R",upload_bac32_manifest$orignalname))

mmc2<-separate(mmc2,PMID_alias, sep=",",into=c("PMID1","PMID2"))
mmc2<-mmc2[unlist(lapply(upload_bac32_manifest$originalname, function(x) grep (x,mmc2$PMID1))),]

mmc2$originalname<-gsub("PMID:2896553\\|","",mmc2$PMID1)

upload_bac32<-merge(upload_bac32_manifest,mmc2,by="originalname",all=T)
upload_bac32[,c(1,3,11:18)]

upload_bac32_tumor<-upload_bac32[!is.na(upload_bac32$PMID1),c(1:2,8:17)]
colnames(upload_bac32_tumor)[1:2]<-c("case_id","name")
upload_bac32_notreportedtumor_blood<-upload_bac32[is.na(upload_bac32$PMID1),1:8]
#remove blood annotation since files are same as tumors
upload_bac32_notreportedtumor_blood<-upload_bac32_notreportedtumor_blood[-which(upload_bac32_notreportedtumor_blood$disease_type == "normal"),]
colnames(upload_bac32_notreportedtumor_blood)<-c("case_id","name","Gender","Diagnosis","Age_at_diagnosis_years","Location_group","originlname","sample_id")
upload_bac32_notreportedtumor_blood<-upload_bac32_notreportedtumor_blood[,-7]
upload_bac32_notreportedtumor_blood$'Alive(0)_Dead(1)'<-"NA"
upload_bac32_notreportedtumor_blood$Location_specific<-"NA"
upload_bac32_notreportedtumor_blood$Survival_time_months<-"NA"
upload_bac32_notreportedtumor_blood$Index_ID<-"NA"
upload_bac32_notreportedtumor_blood$WHO_2007_Grade<-"NA"

upload_bac32_manifest<-rbind(upload_bac32_tumor,upload_bac32_notreportedtumor_blood)
upload_bac32_manifest$name<-paste("https://s3.console.aws.amazon.com/s3/buckets/opendipg/pHGG/",upload_bac32_manifest$name,sep="")
upload_bac32_manifest$Diagnosis<-gsub("glioblastoma","Glioblastoma",upload_bac32_manifest$Diagnosis)
upload_bac32_manifest$Diagnosis<-gsub("anaplastic astrocytoma","Anaplastic astrocytoma",upload_bac32_manifest$Diagnosis)
upload_bac32_manifest$Diagnosis<-gsub("anaplastic oligodendroglioma","Anaplastic oligodendroglioma",upload_bac32_manifest$Diagnosis)
upload_bac32_manifest$Diagnosis<-gsub("diffuse intrinsic pontine glioma","Diffuse intrinsic pontine glioma",upload_bac32_manifest$Diagnosis)
write.csv(upload_bac32_manifest,"~/Documents/CNMC/all_CJ_ETABM_857_bac32k.csv",quote = F,row.names = F)

##############end of ETABM_857 #####################




