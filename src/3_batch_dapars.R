source('~/function/R_sub.R')

dapars_script = "/storage2/huanglu/report/APA/src/dapars/DaPars_main.py"
adv_dapars_script = "/storage2/huanglu/report/APA/src/adv_dapars/adv_dapars_main.py"
genomesizefile = "/storage2/huanglu/report/APA/hg19.genomesize.txt"
each_tissue_bam_info_dir <<- "/storage2/huanglu/report/APA/out/161bam_sep"
bedgraph_dir <<- "/storage2/huanglu/report/APA/out/bedgraph"

run_dapars = function(tissue,dapars_or_adv_dapars,APAdir){
  source('~/function/R_sub.R')
  each_tissue_bam_info_dir <<- "/storage2/huanglu/report/APA/out/161bam_sep"
  bedgraph_dir <<- "/storage2/huanglu/report/APA/out/bedgraph"
  if (dapars_or_adv_dapars=="dapars"){
    scriptfile = paste0(APAdir,"/src/dapars/DaPars_main.py")
    outdir = paste0(APAdir,"/out/dapars_all_prediction_results")
  }else if(dapars_or_adv_dapars=="adv_dapars"){
    scriptfile = paste0(APAdir,"/src/adv_dapars/adv_dapars_main.py")
    outdir = paste0(APAdir,"/out/advdapars_all_prediction_results")
  }else{
    print("software error")
    break
  }
  batch_create_folder(outdir)
  line1 = "Annotated_3UTR=/storage2/huanglu/report/APA/out/hg19_refseq_extracted_3UTR.bed"
  line2 = fread(paste0(each_tissue_bam_info_dir,"/",tissue,"_young.txt")) %>%
    .$Run_s %>%
    paste0(bedgraph_dir,"/",.,".bedgraph") %>%
    paste0(collapse = ",") %>%
    paste0("Group1_Tophat_aligned_Wig=",.)
  line3 = fread(paste0(each_tissue_bam_info_dir,"/",tissue,"_old.txt")) %>%
    .$Run_s %>%
    paste0(bedgraph_dir,"/",.,".bedgraph") %>%
    paste0(collapse = ",") %>%
    paste0("Group2_Tophat_aligned_Wig=",.)
  sub_outdir=paste0(outdir,"/",tissue)
  batch_create_folder(sub_outdir)
  line4 = paste0("Output_directory=",sub_outdir)
  line5 = paste0("Output_result_file=",tissue)
  line6 = paste0("APA_limit_file=/storage2/huanglu/report/APA/out/hsTissue_anno_res_none_removed.txt")
  line7_13 = 
    paste("#Parameters",
    "Num_least_in_group1=1",
    "Num_least_in_group2=1",
    "Coverage_cutoff=30",
    "FDR_cutoff=0.05",
    "PDUI_cutoff=0.2",
    "Fold_change_cutoff=0.59",sep = "\n")
  if (dapars_or_adv_dapars=="dapars"){
    configure_content = paste(line1,line2,line3,line4,line5,line7_13,sep = "\n")
  }else if(dapars_or_adv_dapars=="adv_dapars"){
    configure_content = paste(line1,line2,line3,line4,line5,line6,line7_13,sep = "\n")
  }
write.table(configure_content,paste0(sub_outdir,"/data_configure_",tissue,".txt"),col.names = F,row.names = F, quote = F,sep = "\t")
# cmd = paste0("python2 ",scriptfile," ", outdir,"/data_configure_",tissue,".txt")
# # system(cmd)
# print(cmd)

}
# 
tissue_list = dir(each_tissue_bam_info_dir)%>% no_suffix_vector(.,"_old.txt")%>% no_suffix_vector(.,"_young.txt") %>%unique()
for(i in tissue_list){
  run_dapars(i,dapars_or_adv_dapars = "dapars",APAdir = "/storage2/huanglu/report/APA")
  run_dapars(i,dapars_or_adv_dapars = "adv_dapars",APAdir = "/storage2/huanglu/report/APA")
}
# cl = makeCluster(length(tissue_list))
# parSapply(cl,tissue_list,run_dapars,dapars_or_adv_dapars="dapars",APAdir = "/storage2/huanglu/report/APA")
# stopCluster(cl)
# cl = makeCluster(length(tissue_list))
# parSapply(cl,tissue_list,run_dapars,dapars_or_adv_dapars="adv_dapars",APAdir = "/storage2/huanglu/report/APA")
# stopCluster(cl)