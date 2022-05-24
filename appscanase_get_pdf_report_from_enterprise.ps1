write-host "======== Step: Requesting and Exporting PDF from ASE ========"
# Input variable: $scanName, $aseHostname, $aseApiKeyId, $aseApiKeySecret

$outputContent=(Get-Content .\scanName_var.txt).Replace("`0","")
if ($outputContent -match "Enterprise"){
  $scanNameASE=$outputContent.Replace("`0","") | Select-String -Pattern "AppScan Enterprise job '(.*)'" | % {$_.Matches.Groups[1].Value};
  }
else{
  $scanNameASE=(Get-Content .\scanName_var.txt);
  $jobIdASE=(Get-Content .\jobId_var.txt);
  $scanName="$scanNameASE ($jobIdASE)"
  }

$sessionId=$(Invoke-WebRequest -Method "POST" -Headers @{"Accept"="application/json"} -ContentType 'application/json' -Body "{`"keyId`": `"$aseApiKeyId`",`"keySecret`": `"$aseApiKeySecret`"}" -Uri "https://$aseHostname`:9443/ase/api/keylogin/apikeylogin" -SkipCertificateCheck | Select-Object -Expand Content | ConvertFrom-Json | select -ExpandProperty sessionId);

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession;
$session.Cookies.Add((New-Object System.Net.Cookie("asc_session_id", "$sessionId", "/", "$aseHostname")));
$aseAppId=$(Invoke-WebRequest -WebSession $session -Headers @{"Asc_xsrf_token"="$sessionId"} -Uri "https://$aseHostname`:9443/ase/api/applications/search?searchTerm=$aseAppName" -SkipCertificateCheck | ConvertFrom-Json).id;

$reportId=$(Invoke-WebRequest -Method "POST" -WebSession $session -Headers @{"asc_xsrf_token"="$sessionId" ; "Accept"="application/json"} -ContentType "application/json" -Body "{`"config`":{`"executiveSummaryIncluded`":true,`"advisoriesIncluded`":false,`"issueConfig`":{`"issueAttributeConfig`":{`"showEmptyValues`":false,`"attributeLookups`":[`"applicationname`",`"cvss`",`"comments`",`"description`",`"id`",`"location`",`"overdue`",`"scanname`",`"scanner`",`"severityvalue`",`"status`",`"datecreated`",`"fixeddate`",`"lastupdated`",`"accesscomplexity`",`"accessvector`",`"authentication`",`"availabilityimpact`",`"confidentialityimpact`",`"exploitability`",`"integrityimpact`",`"remediationlevel`",`"reportconfidence`",`"api`",`"callingline`",`"callingmethod`",`"class`",`"classification`",`"databasename`",`"databaseservicename`",`"databasetype`",`"databaseversion`",`"discoverymethod`",`"domain`",`"element`",`"externalid`",`"host`",`"line`",`"package`",`"path`",`"port`",`"projectid`",`"projectname`",`"projectversion`",`"projectversionid`",`"scheme`",`"sourcefile`",`"third-partyid`",`"username`"]},`"includeAdditionalInfo`":true,`"variantConfig`":{`"variantLimit`":1,`"requestResponseIncluded`":true,`"trafficCharactersCount`":0,`"differencesIncluded`":false}},`"applicationAttributeConfig`":{`"showEmptyValues`":false,`"attributeLookups`":[]},`"pdfPageBreakOnIssue`":false,`"sortByURL`":false},`"layout`":{`"reportOptionLayoutCoverPage`":{`"companyLogo`":`"`",`"additionalLogo`":`"`",`"includeDate`":true,`"includeReportType`":true,`"reportTitle`":`"Application Report`",`"description`":`"This report includes important security information about your application.`"},`"reportOptionLayoutBody`":{`"header`":`"`",`"footer`":`"`"},`"includeTableOfContents`":true},`"reportFileType`":`"PDF`",`"issueIdsAndQueries`":[`"scanname=$scanName,status=New,status=Fixed,status=Reopened,status=InProgress,status=Open,status=Passed`"]}" -Uri "https://$aseHostname`:9443/ase/api/issues/reports/securitydetails?appId=$aseAppId" -SkipCertificateCheck | Select-Object -Expand Content | Select-String -Pattern "Report id: (Report\d+)" | % {$_.Matches.Groups[1].Value});

sleep 120;

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession;
$session.Cookies.Add((New-Object System.Net.Cookie("asc_session_id", "$sessionId", "/", "$aseHostname")));
Invoke-WebRequest -WebSession $session -Headers @{"Asc_xsrf_token"="$sessionId"} -Uri "https://$aseHostname`:9443/ase/api/issues/reports/$reportId" -SkipCertificateCheck -OutFile scan_report_pdf.zip -PassThru;

Expand-Archive .\scan_report_pdf.zip -DestinationPath .\

write-host "The scan name $scanName was exported from Appscan Enterprise."