$IISSiteName = "BookStore"
$RepoFolderPath = "C:\inetpub\wwwroot\BookStoreRepo" 
$SiteFolderPath = "C:\inetpub\wwwroot\BookStore"
$AppPoolName = "BookStoreAppPool" 
$HostHeader = "www.BookStore.com"
$GitRepoUrl = "https://github.com/ErazorWhite/DevOps_trainee.git"



if(!(Test-Path("$RepoFolderPath"))) { 
New-Item $RepoFolderPath -type Directory # creating folder with repo
Set-Location -Path $RepoFolderPath # go to location where repo is sited
git clone $GitRepoUrl
Set-Location -Path "$RepoFolderPath\DevOps_trainee" # go to inner folder in cloned repo
} 
else # if folder exist
{
Set-Location -Path "$RepoFolderPath\DevOps_trainee" # go to location where repo is sited
git pull
}

$env:Path += ";C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\" # path to msbuild
nuget restore # restore packages
msbuild # build 


$SiteFolderPath = "$RepoFolderPath\DevOps_trainee\MyBookStore"

if(!(Test-Path ("IIS:\AppPools\$AppPoolName"))) { # if not AppPool -> create it
New-WebAppPool -Name $AppPoolName
}

If((!(Test-Path "IIS:\Sites\$IISSiteName"))){ # if not site -> create it
New-Website -Name $IISSiteName -physicalPath $SiteFolderPath -ApplicationPool $AppPoolName 
}

if(!(Get-WebBinding -Name $IISSiteName)) {
New-WebBinding -Name $IISSiteName -Protocol http -Port 80 -IPAddress "*" -HostHeader $HostHeader
}
if(Get-Website | where {$_.State -eq 'Stopped'})
{
Start-WebSite -Name $IISSiteName
}