#Requires -Version 7.0

param (
  [switch]$InstallDocker,
  [switch]$BuildBugayInitializeDocker,
  [switch]$InitializeLocalDockerContext
)

function Test-IsElevated {
  return (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-Docker {
  param (
    [switch]$InstallDocker
  )

  if (!$InstallDocker) {
    return
  }

  Write-Host 'Installing Docker...'
  $installDirectory = [System.IO.Path]::Combine($Env:LOCALAPPDATA, 'bugay-docker-installer')
  $destinationDirectory = [System.IO.Path]::Combine($Env:USERPROFILE, 'scoop', 'shims')

  if ((Test-Path -Path $installDirectory) -eq $False) {
    New-Item -ItemType Directory -Path $installDirectory
  }

  $git = Get-Command git -ErrorAction SilentlyContinue
  $go = Get-Command go -ErrorAction SilentlyContinue

  if ($null -eq $git || $null -eq $go) {
    Write-Error 'Git and Go are both required to install Docker.'
    Write-Error "Git: ${git}"
    Write-Error "Go:  ${go}"
    return
  }

  $dockerRepoPath = [System.IO.Path]::Combine($installDirectory, 'cli')

  if ((Test-Path -Path $dockerRepoPath) -eq $False) {
    git -C $installDirectory clone git@github.com:docker/cli.git
  }

  # Ensure we've got the latest updates
  git -C $dockerRepoPath fetch origin

  # Pin to the latest commit SHA on the default branch
  $commit = (git -C $dockerRepoPath rev-parse origin/master).Trim()
  $shortSha = $commit.Substring(0, 12)
  $commitDate = (git -C $dockerRepoPath log -1 --format=%cd --date=format:%Y%m%d $commit).Trim()
  $version = "$commitDate-$shortSha"

  Write-Host "Building Docker CLI $version ($commit)..."
  git -C $dockerRepoPath checkout $commit

  # Create a temporary go.mod from vendor.mod
  $src = [System.IO.Path]::Combine($dockerRepoPath, 'vendor.mod')
  $dest = [System.IO.Path]::Combine($dockerRepoPath, 'go.mod')
  Copy-Item $src $dest

  # Build with modules on, using the vendor directory
  $env:GO111MODULE = 'on'
  $env:GOTOOLCHAIN = 'local'

  # https://github.com/docker/cli
  $dockerExe = [System.IO.Path]::Combine($dockerRepoPath, 'build', 'docker.exe')
  go build -C $dockerRepoPath -mod=vendor -o $dockerExe -ldflags "-X github.com/docker/cli/cli/version.Version=$version -X github.com/docker/cli/cli/version.GitCommit=$commit" github.com/docker/cli/cmd/docker

  # Clean up
  Remove-Item $dest

  Copy-Item -Path $dockerExe -Destination $destinationDirectory -Force

  Write-Host "Docker CLI $version installed."
}

function Install-BugayInitializeDocker {
  [CmdletBinding()]
  param (
    [switch]$Build
  )

  function Register-BugayInitializeDockerTask {
    [CmdletBinding()]
    param (
      [string]$Description,
      [string]$TaskName,
      [string]$BinaryPath
    )

    $action = New-ScheduledTaskAction -Execute $BinaryPath
    $trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
    $settings = New-ScheduledTaskSettingsSet `
      -AllowStartIfOnBatteries `
      -DontStopIfGoingOnBatteries `
      -ExecutionTimeLimit ([TimeSpan]::Zero) `
      -RestartCount 3 `
      -RestartInterval (New-TimeSpan -Minutes 1) `
      -Hidden

    Write-Host 'Registering and starting the scheduled task...'
    Register-ScheduledTask -TaskName $TaskName -TaskPath '\Bugay\' -Action $action -Trigger $trigger `
      -Principal $principal -Settings $settings -Description $Description

    Start-ScheduledTask -TaskName $TaskName -TaskPath '\Bugay\'
  }

  $gitRepo = 'git@github.com:zachbugay/Bugay.Initialize.Docker.git'
  $gitRoot = ''
  if ((Test-Path $gitRoot)) {
    $gitRoot = [System.IO.Path]::Combine('D:', $Env:USERNAME, 'source', 'repos')
  }
  else {
    $gitRoot = [System.IO.Path]::Combine($Env:USERPROFILE, 'source', 'repos')
  }

  $dest = [System.IO.Path]::Combine($gitRoot, 'developer-environment')

  if ((Test-Path $dest) -eq $False) {
    New-Item -ItemType Directory -Path $dest
  }

  $bugayInitializeDockerLocation = [System.IO.Path]::Combine($dest, 'Bugay.Initialize.Docker')

  if ((Test-Path -Path $bugayInitializeDockerLocation) -eq $False) {
    git -C $installDirectory clone git@github.com:docker/cli.git
    git -C $dest clone $gitRepo
  }

  git -C $bugayInitializeDockerLocation fetch origin

  $arch = $Env:PROCESSOR_ARCHITECTURE -eq 'AMD64' ? 'win-x64' : 'win-arm64'
  Write-Host "Build value: $Build"

  if ($Build) {
    Write-Host 'Building the binary...'
    $slnPath = [System.IO.Path]::Combine($bugayInitializeDockerLocation, 'Bugay.Initialize.Docker.slnx')
    dotnet clean $slnPath
    dotnet publish $slnPath -c Release -r $arch
  }

  $installDirectory = [System.IO.Path]::Combine($Env:LOCALAPPDATA, 'bugay-docker-installer', 'bin')
  if ((Test-Path $installDirectory -ErrorAction SilentlyContinue) -eq $False) {
    New-Item -Type Directory -Path $installDirectory
  }

  Write-Host 'Installing the binary...'
  $installPath = [System.IO.Path]::Combine($installDirectory, 'Bugay.Initialize.Docker.exe')

  $exePath = [System.IO.Path]::Combine($bugayInitializeDockerLocation, 'src', 'bin', 'Release', 'net10.0', $arch, 'publish', 'Bugay.Initialize.Docker.exe')
  Write-Host "exePath is: $exePath"
  $desc = 'Starts WSL in the background so the Host can communicate with the Docker daemon.'
  $taskName = 'Bugay.Initialize.Docker'
  $existingTask = Get-ScheduledTask -TaskName $taskName -TaskPath '\Bugay\' -ErrorAction SilentlyContinue

  if ($null -ne $existingTask) {
    Write-Host 'Removing existing scheduled task...'
    Get-ScheduledTask -TaskPath '\Bugay\' | Stop-ScheduledTask
    Unregister-ScheduledTask -TaskName $taskName -TaskPath '\Bugay\' -Confirm:$False
    
    $proc = Get-Process -Name 'Bugay.Initialize.Docker' -ErrorAction SilentlyContinue
    if ($null -ne $proc) {
      Stop-Process -InputObject $proc
      $null = Get-Process | Where-Object { $_.HasExited }
    }

    if ([System.IO.File]::Exists($installPath)) {
      Write-Host 'Removing old binary...'
      Remove-Item -Path $installPath
    }
  }

  Copy-Item -Path $exePath -Destination $installPath
  Register-BugayInitializeDockerTask -Description $desc -TaskName $taskName -BinaryPath $installPath
}

function Initialize-LocalDockerContext {
  param(
    [switch]$InitializeLocalDockerContext
  )

  if (!$InitializeLocalDockerContext) {
    return
  }

  Write-Host 'Creating the wsl ssh Docker context...'
  # dprint-ignore
  docker context create --docker host=ssh://wsl --description 'WSL Engine (SSH)' { { .packages.windows.docker_context } }

  Write-Host 'Create the ssh key, add it to ~/.ssh/authorized users in the WSL instance.'
  Write-Host 'Create a .ssh/config'
  Write-Host 'Make sure that the WSL instance has installed openssh-server, docker, and the systemd services are setup'

  $wslIp = ((wsl hostname -I) -split ' ')[0]

  $sshConfigPath = [System.IO.Path]::Combine($Env:USERPROFILE, '.ssh', 'config')
  # TODO: This is different now.
  if (![System.IO.File]::Exists($sshConfigPath)) {
    $content = @"
Host wsl
    HostName $wslIp
    User zacharybugay
    IdentityFile ~/.ssh/local_wsl
    Port 2222
"@
    $content | Out-File -FilePath $sshConfigPath -Encoding utf8
  }
}

if ((Test-IsElevated) -eq $False) {
  Write-Warning 'This script requires local admin privileges. Elevating...'
  $forwardedArgs = foreach ($boundParams in $PSBoundParameters.GetEnumerator()) {
    if ($boundParams.Value -is [switch]) {
      if ($boundParams.Value.IsPresent) { "-$($boundParams.Key)" }
    }
    else {
      "-$($boundParams.Key)"
      $boundParams.Value
    }
  }

  gsudo "& '$($MyInvocation.MyCommand.Source)'" @forwardedArgs
  if ($LastExitCode -eq 999 ) {
    Write-error 'Failed to elevate.'
  }
  return
}

function Initialize-DockerFirewallRules {
  $inboundName = 'WSL 2 Docker'
  $outboundName = 'WSL 2 Docker Outbound'
  $inboundRule = Get-NetFirewallRule -DisplayName $inboundName -ErrorAction SilentlyContinue
  $outboundRule = Get-NetFirewallRule -DisplayName $outboundName -ErrorAction SilentlyContinue

  if ($null -eq $inboundRule) {
    New-NetFirewallRule -DisplayName $inboundName -Direction Inbound -LocalPort 2222 -Action Allow -Protocol TCP
  }

  if ($null -eq $outboundRule) {
    New-NetFirewallRule -DisplayName $outboundName -Direction Outbound -LocalPort 2222 -Action Allow -Protocol TCP
  }
}

Install-Docker -InstallDocker:$InstallDocker

Install-BugayInitializeDocker -Build:$BuildBugayInitializeDocker

Initialize-LocalDockerContext -InitializeLocalDockerContext:$InitializeLocalDockerContext

Initialize-DockerFirewallRules
