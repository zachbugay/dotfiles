Import-Module posh-git
Import-Module Terminal-Icons
Import-Module PSReadLine

$ohMyPoshExt = ".omp.json"
$myTheme = "agnoster" + $ohMyPoshExt

# Kubernetes Defaults
$env:KUBE_EDITOR = "nvim"
$env:EDITOR = "nvim"

$env:XDG_CONFIG_HOME = Join-Path -Path $env:USERPROFILE -ChildPath ".config" 
$env:XDG_DATA_HOME = Join-Path -Path $env:USERPROFILE -ChildPath ".local" -AdditionalChildPath "share"
$env:XDG_STATE_HOME = Join-Path -Path $env:USERPROFILE -ChildPath ".local" -AdditionalChildPath "state"
$env:XDG_CACHE_HOME = Join-Path -Path $env:USERPROFILE -ChildPath ".cache" 
$env:NVIM_LOG_FILE = Join-Path -Path $env:USERPROFILE -ChildPath ".local" -AdditionalChildPath "state", "nvim" 

$directories = @(
    $env:XDG_CONFIG_HOME,
    $env:XDG_DATA_HOME,
    $env:XDG_STATE_HOME,
    $env:XDG_CACHE_HOME,
    $env:NVIM_LOG_FILE
)

foreach ($dir in $directories) {
    if (-not (Test-Path -Path $dir)) {
        New-Item -Type Directory $dir
    }
}

# Posh Prompt
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\$myTheme" | Invoke-Expression

# Functions
function touch { set-content -Path ($args[0]) -Value ($null) }
function Get-ScriptDirectory { Split-Path $MyInvocation.ScriptName }
function Cleanup-AzureResourceGroups { az group list --query "[?name != 'Default-ActivityLogAlerts'].name" | ConvertFrom-Json | % { az group delete --name $_ -f Microsoft.Compute/virtualMachineScaleSets -f Microsoft.Compute/virtualMachines -f Microsoft.Databricks/workspaces -y } }

# If a Dev Drive, or D drive exists.
$devDriveSourcePath = Join-Path -Path "D:" -ChildPath $Env:USERNAME -AdditionalChildPath "source"
$usingDevDrive = ((Get-PSDrive -Name "D") -and (Test-Path $devDriveSourcePath))
if ($usingDevDrive) {
    function cds { Set-Location ($devDriveSourcePath) }
}

#PSReadLine
Set-PSReadLineOption -EditMode vi
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView

# Aliases
Set-Alias -Name open  -Value ii
Set-Alias -Name l     -Value dir
Set-Alias -Name vi    -value nvim
Set-Alias -Name ll    -Value ls
Set-Alias -Name grep  -Value findstr
Set-Alias -Name which -Value gcm

# Check if Code Insiders is installed, and map code => code-insiders.
if ($null -ne (Get-Command code-insiders -ErrorAction SilentlyContinue)) {
    Set-Alias -Name code  -Value code-insiders
}

# Developer Setup
if ($usingDevDrive) {
    # Set the NUGET_PACKAGES environment variable
    # This path has a symlink to ~\.nuget\packages
    $env:NUGET_PACKAGES = "D:\$Env:USERNAME\.nuget\packages"
    $env:npm_config_cache = "D:\$Env:USERNAME\packages\npm"
}
