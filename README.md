# CloneUserOrOrgRepos
powershell scripts to clone all repos that are accessible from your user account from a particular user or organization

## How to use
 1. Clone this repo, add it to your path, or copy the cloneGithub.ps1 into your path.
 2. start powershell, navigate to the directory that you want all the repos cloned too
 3. run `.\cloneGithub.ps1 xenoputtss` (replace xenoputtss with any user or org you want)
    1. if it is your first time, add your github personal access token to the config file (should open file for you automaticly)
        rerun command again

### update all?
 in the same directory as step 2 above, just run `.\cloneGithub.ps1` and this will check for updates for all users/orgs previously cloned

 
