#! /usr/bin/powershell
$files = Get-ChildItem -Recurse -File -Path /opt/samples
$files += Get-ChildItem -Recurse -File -Path /mnt/hgfs/Analysis
foreach($file in $files){
	#$pcap = $file.Name -replace '.pcap',''
	$string = '/test_/c\    Exec        $test = \"test_' + $file.Name +'\";'
	& sed -i "$string" /etc/nxlog/nxlog.conf
	service nxlog restart
	Start-Sleep -Seconds 5
	& tcpreplay -i eth1 -M 20 $file.FullName
	Start-Sleep -Seconds 60
}
sed -i '/test_/c\    Exec        $test = \"test_\";' /etc/nxlog/nxlog.conf
service nxlog restart
