APA_dir_list=c("/storage2/huanglu/report/APA/out/advdapars_all_prediction_results","/storage2/huanglu/report/APA/out/dapars_all_prediction_results")
resultdf=""
all_pass_df=""
for (i in APA_dir_list){
  if(i=="/storage2/huanglu/report/APA/out/advdapars_all_prediction_results"){
    study="advdapars"
  }else if(i=="/storage2/huanglu/report/APA/out/dapars_all_prediction_results"){
    study="dapars"
  }
 for(j in dir(i,full.names = T) %>% grep("dustbin",.,invert = T,value = T)){
   tissue=basename(j)%>%sub("Brain_","",.)%>%sub("_All_Prediction_Results.txt","",.)
   eacResultDF = fread(paste0(j,"/",basename(j),"_All_Prediction_Results.txt"),data.table = F)
   Anum=colnames(eacResultDF)%>%grep("^A",.,value = T)%>%grep("long",.,value = T)%>%length()
   Bnum=colnames(eacResultDF)%>%grep("^B",.,value = T)%>%grep("long",.,value = T)%>%length()
   diffpass=filter(eacResultDF,abs(PDUI_Group_diff)>=0.2)%>%nrow()
   FDR_cutoff.pass=filter(eacResultDF,adjusted.P_val<0.05)%>%nrow()
   allpass=filter(eacResultDF,Pass_Filter=="Y")
   
   if(dim(allpass)[1]!=0){
   allpass_extend=data.frame(study,tissue,allpass)[,c(1,2,3,4,5,6,tail(1:ncol(allpass)+2,6))]
   all_pass_df=rbind(all_pass_df,allpass_extend)
   }
   
   allpass_num=allpass%>%nrow()
   eachsum=c(study=study,tissue=tissue,young_num=Anum,old_num=Bnum,PDUI_cutoff.pass=diffpass,FDR_cutoff.pass=FDR_cutoff.pass,all.pass.num=allpass_num)
   resultdf=rbind(resultdf,eachsum)
 }
}
resultdf=resultdf%>%as.data.frame()%>%.[-1,]
all_pass_df=all_pass_df%>%as.data.frame()%>%.[-1,]
write.table(resultdf,"/storage2/huanglu/report/APA/out/sum_result20180805.txt",row.names = F,sep = "\t",quote = F)
write.table(all_pass_df,"/storage2/huanglu/report/APA/out/all_pass_df20180811.txt",row.names = F,sep = "\t",quote = F)
