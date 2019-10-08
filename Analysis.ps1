#! /usr/bin/powershell
#$files = Get-ChildItem -Recurse -File -Path /opt/samples
nsm --all --stop
$files = Get-ChildItem -Recurse -File -Path /opt/samples
$files += Get-ChildItem -Recurse -File -Path /mnt/hgfs/Analysis
Set-Location -Path /var/log/analysis
Remove-Item -Force -Recurse /var/log/analysis/*
Remove-Item -Force -Recurse /var/log/ship/*
foreach($file in $files){
	& /opt/bro/bin/bro -r $file.FullName /etc/nsm/analysis.bro -C
	& /usr/bin/suricata -c /etc/nsm/suricata.yaml -r $file.FullName --runmode autofp -k none
	$logs = Get-ChildItem -File -Path /var/log/analysis/*.log
	foreach($log in $logs){
		$pcap_name = $file.Name -replace ".pcap",""
		$log_name = $log.Name -replace ".log",""
		$file_name = $file.Name + "_" + $log_name
		Move-Item $log.FullName "/var/log/ship/$file_name.log"
	}
	$file_name = $file.Name + "_eve.json"
	Move-Item /var/log/analysis/eve.json "/var/log/ship/$file_name"
}
