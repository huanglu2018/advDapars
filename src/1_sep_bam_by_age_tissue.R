###brain APA
###use dapars VS adv_dapars 
###use v6p bam id system
###group1 <= 40yr; group2 >= 60yr

source('~/function/R_sub.R')

all_v6p_srrlist_nodup_file = "/storage2/huanglu/mount/data3_huanglu_213/expression_matrices/stringtie_output/expression_matrices_169ws/stringtie_input/sample_info/SRR_list/2018_07_17_09_53_29_all_tissues_noDup_noFormer.txt"
all_sample_info_file = "/storage2/huanglu/mount/data2_huanglu_213/sample_info/[SRR_GTExID_bodysite]SraRunTable.txt"
all_ind_info_file = "/storage2/huanglu/mount/data2_huanglu_213/sample_info/[GTExshortID_cov]phs000424.v6.pht002742.v6.p1.c1.GTEx_Subject_Phenotypes.GRU2.txt"
APA_dir = "/storage2/huanglu/report/APA"

outdir = paste0(APA_dir,"/out")
bam_sep_dir = paste0(outdir,"/bam_sep")
batch_create_folder(c(outdir,bam_sep_dir))

bam_dir_df = fread(all_v6p_srrlist_nodup_file,data.table = F) %>%
  mutate(SRRID = (basename(.[,6]) %>% no_suffix_vector(".sort.bam"))) %>%
  .[,c("sra/left_read","SRRID")] %>%
  .[grep("brain",.$`sra/left_read`,ignore.case=T),] ##select brain

sample_and_ind_info = fread(all_sample_info_file,data.table = F) %>% 
  filter(.,Run_s %in% (basename(bam_dir_df$`sra/left_read`) %>% no_suffix_vector(".sort.bam"))) %>%
  .[,c("Run_s","Sample_Name_s","submitted_subject_id_s","body_site_s","sex_s")] %>%
  merge(.,fread(all_ind_info_file,data.table = F),by.x = "submitted_subject_id_s",by.y = "SUBJID",all.x = T) %>%
  merge(.,bam_dir_df,by.x = "Run_s",by.y = "SRRID")

each_tissue_sep = function(tissuename,summary_table,outdir){
  tissuename_mod = tissuename %>%
    str_replace_all(., " - ", "_") %>%
    gsub("[(*)]", "",.) %>% 
    str_replace_all(., " ", "_")
    
  #young_group
  filter(summary_table,body_site_s==tissuename,AGE<=40) %>%
  write.table(.,paste0(outdir,"/bam_sep/",tissuename_mod,"_young.txt"),row.names = F,quote = F,sep = "\t")
  #old_group
  filter(summary_table,body_site_s==tissuename,AGE>=60) %>%
  write.table(.,paste0(outdir,"/bam_sep/",tissuename_mod,"_old.txt"),row.names = F,quote = F,sep = "\t")
}

for (i in sample_and_ind_info$body_site_s %>% unique()){
  each_tissue_sep(i,sample_and_ind_info,outdir)
}
