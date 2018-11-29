Param ($userRepo)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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

    $url = "https://api.github.com/orgs/$organisation/repos?per_page=200&access_token=$accessToken"

    #Lazy way of determining if $organisation is a user or org
    try { 
        Invoke-WebRequest invoke-webrequest -Uri $url 
    } catch {
        $url = "https://api.github.com/users/$organisation/repos?per_page=200&access_token=$accessToken"
    }

    # $url
    #Clone everything using SSH
    $githubReponse = ((invoke-webrequest -Uri $url).Content | ConvertFrom-Json) 
    foreach($repo in $githubReponse){
        #check if directory exists
        if(Test-Path $repo.name){
            #update repo
            "Updating "+$repo.name
            Push-Location $repo.name
            %{git fetch --all}
            Pop-Location
        }else{
            #clone new repo
            %{git clone $repo.ssh_url}
        }
    # $repo.ssh_url
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


