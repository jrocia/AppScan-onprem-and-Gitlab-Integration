write-host "======== Step 5 - Converting ASE XML to Gitlab JSON ========"
Expand-Archive .\scan_report.zip -DestinationPath .\
$header="{`"version`":`"14.0.4`",`"vulnerabilities`":[";
echo $header | Out-File -Append -NonewLine .\gl-dast-report.json;
$files=$(Get-Item -Path *.xml);
ForEach ($file in $files){
  [XML]$xml = Get-Content $file;
  $countIssues=$xml.'xml-report'.'issue-group'.item.count-1
  [array]$totalIssues=@(0..$countIssues);
  ForEach ($i in $totalIssues) {
    $ErrorActionPreference = 'SilentlyContinue';
    $nameMessageDescriptionCode=$xml.'xml-report'.'issue-group'.item[$i].'issue-type'.ref;
    $nameMessageDescriptionValue=($xml.'xml-report'.'issue-type-group'.item | Where-Object {$_.id -eq $xml.'xml-report'.'issue-group'.item[$i].'issue-type'.ref}).name.Replace('"','');
    $urlLocation=$xml.'xml-report'.'issue-group'.item[$i].'attributes-group'.attribute[5].value.Replace('\','\\');
    $paramElement=$xml.'xml-report'.'issue-group'.item[$i].'attributes-group'.attribute[36].value.Replace('"','');
    $path=$xml.'xml-report'.'issue-group'.item[$i].'attributes-group'.attribute[41].value.Replace('\','\\');
    $sevValue=$xml.'xml-report'.'issue-group'.item[$i].'attributes-group'.attribute[9].value.Replace('Information','Info').Replace('Use CVSS','Unknown');
    $issueReason=$xml.'xml-report'.'issue-group'.item[$i].'variant-group'.item.reasoning.Replace('"','');
    $cveValue="$(Get-Random)"+"appscanid"+"$($xml.'xml-report'.'issue-group'.item[$i].'attributes-group'.attribute.value[4])"+"$($xml.'xml-report'.'issue-group'.item[$i].'attributes-group'.attribute.value[27])";
    $appscanId=$xml.'xml-report'.'issue-group'.item[$i].'attributes-group'.attribute[4].value;
    $idIssues="{`"id`":`"$(Get-Random)`",`"category`":`"dast`",`"name`":`"$nameMessageDescriptionValue`",`"message`":`"$nameMessageDescriptionValue in $path`",`"description`":`"$issueReason`",`"cve`":`"$cveValue`",`"severity`":`"$sevValue`",`"confidence`": `"Unknown`",`"scanner`":{`"id`":`"appscan_standard`",`"name`":`"HCL AppScan Standard`"},`"location`":{`"param`":`"$paramElement`",`"method`":`"$paramElement->Appscan_Report_Id_$appscanId`",`"hostname`":`"$urlLocation`"},`"identifiers`":[{`"type`":`"appscan_standard`",`"name`":`"HCL AppScan Enterprise How to Fix Session`",`"value`":`"appscan_standard`",`"url`":`"https://$aseHostname`:9443/ase/api/issuetypes/howtofix?issueTypeId=wf-security-check-$nameMessageDescriptionCode`"},{`"type`":`"cwe`",`"name`":`"CWE-699`",`"value`":`"699`",`"url`":`"https://cwe.mitre.org/data/definitions/699.html`"}]}," | Out-File -Append -NonewLine .\gl-dast-report.json;
  }
}
$dastReport = Get-Content .\gl-dast-report.json;
$dastReport = $dastReport.SubString(0,$dastReport.Length-1) | Out-File -NonewLine .\gl-dast-report.json;
"],`"scan`":{`"scanned_resources`":[" | Out-File -Append -NonewLine .\gl-dast-report.json;
ForEach ($file in $files){
  [XML]$xml = Get-Content $file;
  $resItems=$xml.'xml-report'.'entity-group'.item.'url-name'.count-1
  [array]$totalResItems=@(0..$resItems);
  if ($xml.'xml-report'.'entity-group'.item.'url-name'.count -eq 1){
    $resItem=$xml.'xml-report'.'entity-group'.item.'url-name'.Replace('\','\\');
    $idResItems="{`"method`":`"GET`",`"type`":`"url`",`"url`":`"$resItem`"}," | Out-File -Append -NonewLine .\gl-dast-report.json
  }      
  else{
    ForEach ($i in $totalResItems) {
      $resItem=$xml.'xml-report'.'entity-group'.item[$i].'url-name'.Replace('\','\\');
      $idResItems="{`"method`":`"GET`",`"type`":`"url`",`"url`":`"$resItem`"}," | Out-File -Append -NonewLine .\gl-dast-report.json;
    }
  }
}
$dastReport = Get-Content .\gl-dast-report.json;
$dastReport = $dastReport.SubString(0,$dastReport.Length-1) | Out-File -NonewLine .\gl-dast-report.json;
$reportDateTime=$xml.'xml-report'.layout.'report-date-and-time'.Replace('/','-').Replace(' ','T');
$footer="],`"analyzer`":{`"id`":`"appscan_standard`",`"name`":`"appscan_standard`",`"vendor`":{`"name`":`"HCL`"},`"version`":`"10.0.7`"},`"scanner`":{`"id`":`"dast`",`"name`":`"Find Security Issues`",`"url`":`"https://help.hcltechsw.com/appscan/Standard/10.0.7/topics/home.html`",`"vendor`":{`"name`":`"HCL`"},`"version`":`"10.0.7`"},`"type`":`"dast`",`"start_time`":`"$reportDateTime`",`"end_time`":`"$reportDateTime`",`"status`":`"success`"}}" | Out-File -Append -NonewLine .\gl-dast-report.json;
write-host "======== Step 5 finished ========"