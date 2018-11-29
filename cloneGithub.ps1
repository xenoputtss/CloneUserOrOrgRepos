Param ($organisation)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Check for config file and Tokens
$accessToken = ""
$configPath = "$ENV:UserProfile\cloneGithub.json"
if( Test-Path $configPath){
    $configOutput = Get-Content $configPath | Out-String | ConvertFrom-Json
    $accessToken = $configOutput.githubPersonalAccessToken
}else{
    $configOutput = ConvertTo-Json @{ githubPersonalAccessToken="YOUR GITHUB PERSONAL AUTH TOKEN"; }
    Out-File -FilePath $configPath  -InputObject $configOutput 
    start $configPath
    return
}

return
mkdir $organisation
pushd $organisation

#Your GITHUB personal access token
$url = "https://api.github.com/orgs/$organisation/repos?per_page=200&access_token=$accessToken"

#Lazy way of determining if $organisation is a user or org
try { 
    Invoke-WebRequest invoke-webrequest -Uri $url 
} catch {
    $url = "https://api.github.com/users/$organisation/repos?per_page=200&access_token=$accessToken"
}

# $url
#Clone everything using SSH
(invoke-webrequest -Uri $url).Content | ConvertFrom-Json | %{$_.ssh_url}  | % {git clone $_}


popd 
