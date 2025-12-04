<#
.SYNOPSIS
    Request an interactive Hellbender Slurm allocation and connect VS Code remotely from PowerShell on Windows.

.DESCRIPTION
    This script is a PowerShell port of start_hellbender.sh / start_hellbender_mac.sh.
    It requests an interactive allocation on the remote host (hellbender), polls until a node is assigned
    and then launches VS Code Remote-SSH to connect to that node.

    Prerequisites (local machine):
    - OpenSSH client available (ssh on PATH)
    - VS Code installed with Remote-SSH extension
    - code CLI available on PATH (VS Code: Install code command in PATH)

.PARAMETER RemoteHost
    Remote host alias or hostname to connect to. Default: hellbender.

.PARAMETER Time
    Allocation time string for salloc (e.g. 1:00:00). Default: 1:00:00.

.PARAMETER Partition
    Partition name to request. Default: interactive.

.PARAMETER PollLoops
    Number of polling attempts to wait for the allocation. Default: 30.

.PARAMETER PollInterval
    Seconds to wait between polls. Default: 2.

#>

param(
    [string]$RemoteHost = 'hellbender',
    [string]$Time = '1:00:00',
    [string]$Partition = 'interactive',
    [int]$PollLoops = 30,
    [int]$PollInterval = 2
)

function Fail {
    param([string]$message, [int]$code = 1)
    Write-Host "X $message" -ForegroundColor Red
    exit $code
}

Write-Host "Requesting resources from $RemoteHost..."

# Check prerequisites
$sshCmd = Get-Command ssh -ErrorAction SilentlyContinue
if (-not $sshCmd) {
    Fail -message "ssh not found in PATH. Install OpenSSH client or ensure ssh is available."
}

$codeCmd = Get-Command code -ErrorAction SilentlyContinue
if (-not $codeCmd) {
    Write-Host "Warning: code CLI not found in PATH. VS Code may not launch automatically." -ForegroundColor Yellow
}

# Helper to call remote command via ssh and return trimmed output
function Invoke-Remote {
    param([string]$hostName, [string]$remoteCmd)
    $raw = & ssh $hostName $remoteCmd 2>$null
    if ($LASTEXITCODE -ne 0) { return $null }
    $result = ($raw -join "`n").Trim()
    $result = $result -replace "`r", ''
    return $result
}

# Get current job count on the remote cluster
$initialJobsRaw = Invoke-Remote -hostName $RemoteHost -remoteCmd 'squeue -u $USER -h | wc -l'
if ($null -eq $initialJobsRaw) {
    Fail -message "Unable to query remote squeue; make sure SSH access and Slurm commands are available on the remote host." -code 2
}

[int]$initial_jobs = 0
try { 
    $initial_jobs = [int]$initialJobsRaw.Trim() 
} catch { 
    $initial_jobs = 0 
}

# Start salloc on the remote host in detached mode (nohup) so ssh returns immediately.
Write-Host "Requesting interactive allocation on $RemoteHost..."
$allocCmd = 'nohup salloc --time=' + $Time + ' --partition=' + $Partition + ' sleep 3600 >/dev/null 2>&1 &'

# Run allocation remotely
& ssh $RemoteHost $allocCmd
if ($LASTEXITCODE -ne 0) {
    Write-Host "Warning: allocation request exit code was $LASTEXITCODE (it may still have queued)." -ForegroundColor Yellow
}

Write-Host "Waiting for node allocation..."

for ($i = 1; $i -le $PollLoops; $i++) {
    # Get the most recent interactive node and job id
    $nodeRaw = Invoke-Remote -hostName $RemoteHost -remoteCmd 'squeue -u $USER -h -p interactive -o "%N" | head -n 1'
    $jobidRaw = Invoke-Remote -hostName $RemoteHost -remoteCmd 'squeue -u $USER -h -p interactive -o "%i" | head -n 1'
    $currentJobsRaw = Invoke-Remote -hostName $RemoteHost -remoteCmd 'squeue -u $USER -h | wc -l'

    # Normalize
    $node = ''
    $jobid = ''
    $currentJobs = 0

    if ($null -ne $nodeRaw) { 
        $node = $nodeRaw.Trim() 
    }
    if ($null -ne $jobidRaw) { 
        $jobid = $jobidRaw.Trim() 
    }
    try { 
        $currentJobs = [int]($currentJobsRaw.Trim()) 
    } catch { 
        $currentJobs = 0 
    }

    if ((-not [string]::IsNullOrWhiteSpace($node)) -and ($currentJobs -gt $initial_jobs)) {
        Write-Host "OK Allocated node: $node" -ForegroundColor Green
        Write-Host "OK Job ID: $jobid" -ForegroundColor Green

        Start-Sleep -Seconds 2

        Write-Host "Opening VS Code and connecting to $node..."

        if ($codeCmd) {
            try {
                $remoteArg = "ssh-remote+$node"
                & code --remote $remoteArg
            } catch {
                Write-Host "Failed to launch VS Code via code CLI. Try opening VS Code and connecting to ssh-remote+$node manually." -ForegroundColor Yellow
            }
        } else {
            Write-Host "Run in VS Code: Remote-SSH: Connect to Host... then choose $node" -ForegroundColor Yellow
        }

        Write-Host ""
        Write-Host "OK VS Code should now be connecting to $node" -ForegroundColor Green
        Write-Host "OK Click Open Folder in VS Code to select your working directory" -ForegroundColor Green
        Write-Host "OK Your session will expire in $Time" -ForegroundColor Green
        Write-Host ""

        Write-Host "Current jobs:"
        $jobsOutput = Invoke-Remote -hostName $RemoteHost -remoteCmd 'squeue -u $USER'
        Write-Host $jobsOutput
        Write-Host ""
        $cancelMsg = "To cancel this specific job: ssh " + $RemoteHost + " scancel " + $jobid
        Write-Host $cancelMsg
        exit 0
    }

    Write-Host -NoNewline '.'
    Start-Sleep -Seconds $PollInterval
}

Write-Host ""
Write-Host "X Timeout waiting for node allocation" -ForegroundColor Red
$checkMsg = "Check status with: ssh " + $RemoteHost + " squeue -u YOUR_USERNAME"
Write-Host $checkMsg
exit 1
