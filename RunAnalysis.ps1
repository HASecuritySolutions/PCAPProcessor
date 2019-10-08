#! /usr/bin/powershell
#$files = Get-ChildItem -Recurse -File -Path /opt/samples
$files = Get-ChildItem -Recurse -File -Path /opt/samples/pcap-links/https.pcap
#$files += Get-ChildItem -Recurse -File -Path /mnt/hgfs/Analysis
Set-Location -Path /var/log/analysis
Remove-Item -Force -Recurse /var/log/analysis/*
foreach($file in $files){
	& /opt/bro/bin/bro -r $file.FullName /etc/nsm/analysis.bro -C
	& /usr/bin/suricata -c /etc/nsm/suricata.yaml -r $file.FullName --runmode autofp -k none

	Copy-Item -Force /etc/nxlog/analysis.orig /etc/nxlog/analysis.conf

	$conn = '<Input bro_conn>
    Module      im_file
    File        "/var/log/analysis/conn.log"
    Exec        $message = $raw_event;
    Exec        $type = "bro_conn";
    Exec        $test = "test_' + $file.Name + '";
    CloseWhenIdle TRUE
</Input>

<Route conn_route>
	Path	bro_conn => bro_out
</Route>
'
	if(Test-Path -Path /var/log/analysis/conn.log){
		$conn | Out-File -Append /etc/nxlog/analysis.conf -Encoding Ascii
	}
        $string = '/test_/c\    Exec        $test = \"test_' + $file.Name +'\";'
        & sed -i "$string" /etc/nxlog/analysis.conf
	& /usr/bin/nxlog-processor -c /etc/nxlog/analysis.conf
}
#Copy-Item -Force /etc/nxlog/analysis.orig /etc/nxlog/analysis.conf
#    Path        bro_conn,bro_dhcp,bro_dns,bro_dpd,bro_files,bro_ftp,bro_http,bro_irc,bro_kerberos,bro_mysql,bro_notice,bro_rdp,bro_signatures,bro_smtp,bro_snmp,bro_software,bro_ssh,bro_ssl,bro_tunnel,bro_weird,bro_x509 => bro_out
