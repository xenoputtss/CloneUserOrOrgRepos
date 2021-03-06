Param ($userRepo)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function cloneOrUpdateRepo{
    Param ($repo)

    #check if directory exists
    if(Test-Path $repo.name){
        #update repo
        "Updating "+$repo.name
        Push-Location $repo.name
        %{git fetch --all --quiet}
        Pop-Location
    }else{
        #clone new repo
        "Cloning New Repo " + $repo.name
        %{git clone $repo.ssh_url  --quiet}  
    }
}

function doUserInfoCloneing($userName, $ApiKey){
    #does the user already have a starred directory
    if(-Not (Test-Path "starred")){
        mkdir "starred"
    }
    Push-Location "starred"

    $starUrl = "https://api.github.com/users/$userName/starred?access_token=$ApiKey"
    $starUrl
    $githubReponse = ((invoke-webrequest -Uri $starUrl).Content | ConvertFrom-Json) 


    foreach($repo in $githubReponse){
        $repo.name
        cloneOrUpdateRepo $repo 
    }
    Pop-Location 
}

function doRepoWork {
    Param ($organisation)
        
    $organisation
    #Check for config file and Tokens
    $accessToken = ""
    $configPath = "$ENV:UserProfile\cloneGithub.json"
    if(-Not (Test-Path $configPath)){
        $configOutput = ConvertTo-Json @{ githubPersonalAccessToken="YOUR GITHUB PERSONAL AUTH TOKEN"; }
        Out-File -FilePath $configPath  -InputObject $configOutput 
        Start-Process $configPath
        return
    }else{
        $configOutput = Get-Content $configPath | Out-String | ConvertFrom-Json
        $accessToken = $configOutput.githubPersonalAccessToken
    }

    #does this user/org already have a directory?
    if(-Not (Test-Path $organisation)){
        mkdir $organisation
    }

    Push-Location $organisation

    $params = "per_page=200&type=all&sort=full_name"
    $url = "https://api.github.com/orgs/$organisation/repos?$params&access_token=$accessToken"
    $isUser = $false
    #Lazy way of determining if $organisation is a user or org
    try { 
        Invoke-WebRequest -Uri $url 
    } catch {
        $url = "https://api.github.com/users/$organisation/repos?$params&access_token=$accessToken"
        $isUser=$true
    }

    #Clone everything using SSH
    $url
    $githubReponse = ((invoke-webrequest -Uri $url).Content | ConvertFrom-Json) 

    foreach($repo in $githubReponse){
        # $repo.name
        cloneOrUpdateRepo $repo 
    }
    
    if ($isUser -eq $true) {
        doUserInfoCloneing $organisation $accessToken
    } 



    Pop-Location 
}


#if org/user not passed in, then find all local directories and try that (like a "update all")
If (Test-Path variable:\$userRepo){
    "User/Org Not passed in, doing an UPDATE ALL"
    ($PSScriptRoot)+"\"+($MyInvocation.MyCommand.Name)
    Get-ChildItem | Where-Object{ $_.PSIsContainer } | Select-Object Name | ForEach-Object{ doRepoWork($_.Name) }
}else{
    doRepoWork($userRepo)
}


