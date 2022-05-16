source activate python2

for file in $(find /storage2/huanglu/report/APA/out/advdapars_all_prediction_results -name *configure*)
do
	while(( `ps -ef |grep dapars|grep -v grep|grep -v 4_run_dapars_iter|wc -l` >= 4 ))
	do
		sleep 600
done

echo "start new process on "$file
nohup python2 /storage2/huanglu/report/APA/src/adv_dapars/adv_dapars_main.py $file > /storage2/huanglu/report/APA/out/advdapars_all_prediction_results/$(echo $file|awk -F 'data_configure_' '{print$NF}')_`date +%Y%m%d`_log.txt 2>&1 &

done

for file2 in $(find /storage2/huanglu/report/APA/out/dapars_all_prediction_results -name *configure*)
do
	while(( `ps -ef |grep dapars|grep -v grep|grep -v 4_run_dapars_iter|wc -l` >= 4 ))
	do
		sleep 600
done

echo "start new process on "$file2
nohup python2 /storage2/huanglu/report/APA/src/dapars/DaPars_main.py $file2 > /storage2/huanglu/report/APA/out/dapars_all_prediction_results/$(echo $file2|awk -F 'data_configure_' '{print$NF}')_`date +%Y%m%d`_log.txt 2>&1 &

done
