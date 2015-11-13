﻿#Specify variables
$User = "admin@tenant.onmicrosoft.com"
$SiteURL = "https://tenant.sharepoint.com"
$DocLibName = "Documents"
$FileName = "D:\Test.pptx"

#Add references to SharePoint client assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString

Try {
#Bind to site collection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User,$Password)
$Context.Credentials = $Creds
#Retrieve list
$List = $Context.Web.Lists.GetByTitle($DocLibName)
$Context.Load($List)
$Context.ExecuteQuery()
}
Catch {
Write-Host "Unable to open list" $SiteURL -ForegroundColor Red
}

$TimeTaken = Measure-Command {
Try {
#Upload file
$File = Get-Item $FileName
Write-Host "Uploading" $File.Name"..." -ForegroundColor Yellow
$FileStream = New-Object IO.FileStream($File.FullName,[System.IO.FileMode]::Open)
$FileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
$FileCreationInfo.Overwrite = $true
$FileCreationInfo.ContentStream = $FileStream
$FileCreationInfo.URL = $File.Name
$Upload = $List.RootFolder.Files.Add($FileCreationInfo)
$Context.Load($Upload)
$Context.ExecuteQuery()
}
Catch {
Write-Host "Unable to upload file" $File.Name  -ForegroundColor Red
}
}

$TotalSeconds = [INT]$TimeTaken.TotalSeconds
Write-Host "-Upload took" $TotalSeconds "Seconds" -ForegroundColor Green