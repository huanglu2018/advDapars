source('~/function/R_sub.R')

dapars_script = "/storage2/huanglu/report/APA/src/dapars/DaPars_main.py"
adv_dapars_script = "/storage2/huanglu/report/APA/src/adv_dapars/adv_dapars_main.py"
genomesizefile = "/storage2/huanglu/report/APA/hg19.genomesize.txt"
each_tissue_bam_info_dir = "/storage2/huanglu/report/APA/out/bam_sep"
bedgraph_dir = "/storage2/huanglu/report/APA/out/bedgraph"

run_genomecoveragebed = function(bam_list_file,genomesizefile,bedgraph_dir){
  source('~/function/R_sub.R')
  bam_list = fread(bam_list_file,data.table = F)[,10]
  for(bam_dir in bam_list){
    bedgraph_file = paste0(bedgraph_dir,"/",basename(bam_dir)%>%gsub(".sort.bam","",.),".bedgraph")
    cmd = paste0("/storage2/huanglu/software/bedtools2/bin/genomeCoverageBed -bg -ibam ",bam_dir," -g ",genomesizefile," > ",bedgraph_file)
    system(cmd)
  }
}

cl = makeCluster(20)
parSapply(cl,dir(each_tissue_bam_info_dir,full.names = T),run_genomecoveragebed,genomesizefile = genomesizefile,bedgraph_dir =bedgraph_dir)
rename("/storage2/huanglu/report/APA/out/test","/storage2/huanglu/report/APA/out/test2")
