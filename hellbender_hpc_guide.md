# Hellbender HPC Quick Start Guide

This guide covers getting started with neural modeling on Mizzou's Hellbender HPC system.

## Table of contents

- [Prerequisites](#prerequisites)
- [What You Can Do with Hellbender](#what-you-can-do-with-hellbender)
- [Access Methods](#access-methods)
  - [OnDemand Web Interface](#method-1-ondemand-web-interface)
  - [SSH Access via VS Code](#method-2-ssh-access-via-vs-code)
    - [Automating node allocation with helper scripts](#automating-node-allocation-with-helper-scripts)
- [Environment Setup](./python_environment_setup.md)
- [Using Slurm on Hellbender](#using-slurm-on-hellbender)
- [Best Practices](#best-practices)
- [Common Issues](#common-issues)
- [Useful Commands Reference](#useful-commands-reference)
- [Additional Resources](#additional-resources)
- [Getting Help](#getting-help)

## Prerequisites

### Create Hellbender Account

Apply for an account through the [HPC Service Request Form](https://missouri.service-now.com/sp?id=sc_cat_item&sys_id=your_form_id).

**Before starting:**
You may want to review these resources for background.

- Understand basic HPC concepts: [Guide to HPC - Nodes and Processors](https://kinda-technical.com/hpc-guide)
- Review the [Hellbender Wiki](https://wiki.rnet.missouri.edu/confluence/display/HPCC/Hellbender)

## Access Methods

Hellbender can be accessed through a web interface or via SSH. Choose based on your needs:

| Method         | Best For                                              | Parallel Processing |
| -------------- | ----------------------------------------------------- | ------------------- |
| OnDemand (Web) | Learning, single-node or small-scale work             | Limited             |
| SSH (VS Code)  | Complex, multi-node work and submitting jobs to Slurm | Full support        |

## Method 1: OnDemand Web Interface

Perfect for getting started quickly or running small, single-node analyses.

### Setup Steps

1. Go to [Hellbender OnDemand](https://ondemand.rnet.missouri.edu/)
2. Log in with your Mizzou credentials
3. Select "Code Server"
4. Configure your session:
   - **Number of nodes:** How many compute nodes (default: 1)
   - **Time in hours:** How long to run (default: 1 hour)
5. Click "Launch"
6. After a brief wait, click "Connect to VS Code"

### Working in OnDemand

Your directory structure:

```
/home/[pawprint]/
└── data/           # Your working directory by default
```

To open your data folder:

1. Click the three horizontal lines (top-left menu)
2. Navigate to: `home/[pawprint]/data`
3. Work normally: `git clone`, `python file.py`, etc.

Your session will automatically end when your allocated time expires.

## Method 2: SSH Access via VS Code

Recommended for serious computational work and parallel processing.

### Initial Setup (One-Time)

#### Step 1: Generate SSH Key

If you don't have an SSH key:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Follow the prompts. This creates a secure key pair for authentication.

#### Step 2: Configure VS Code SSH

1. Open VS Code
2. Open Command Palette:
   - **Mac:** `Cmd + Shift + P`
   - **Windows/Linux:** `Ctrl + Shift + P`
3. Select: `Remote-SSH: Open SSH Configuration File…`
4. Add this configuration at the bottom:

```
Host hellbender
  HostName hellbender-login.rnet.missouri.edu
  User [your_pawprint]

# Proxy jump through Hellbender
Host c*
  ProxyJump hellbender
  User [your_pawprint]
  HostName %h
```

Replace `[your_pawprint]` with your actual pawprint.

#### Step 3: Copy SSH Key to Hellbender

**On Mac/Linux:**

```bash
ssh-copy-id [your_pawprint]@hellbender-login.rnet.missouri.edu
```

**On Windows (paste the function into PowerShell, then run the command):**

```powershell
function ssh-copy-id([string]$userAtMachine){
    $publicKey = "$ENV:USERPROFILE" + "/.ssh/id_rsa.pub"
    if (!(Test-Path "$publicKey")){
        Write-Error "ERROR: failed to open ID file '$publicKey': No such file"
    }
    else {
        & cat "$publicKey" | ssh $userAtMachine "umask 077; test -d .ssh || mkdir .ssh ; cat >> .ssh/authorized_keys || exit 1"
    }
}
```

Then run:

```powershell
ssh-copy-id [your_pawprint]@hellbender-login.rnet.missouri.edu
```

### Regular Workflow (Every Session)

Do not run VS Code on Hellbender's login node. First allocate a compute node, then connect to that node with VS Code. The repository includes helper scripts to automate this allocation-and-connect flow. Make sure your SSH configuration and keys are set up before using the scripts.

Also make sure the `code` CLI is available in your local shell (the scripts use it to open VS Code):

- macOS: Open VS Code → Command Palette (Cmd + Shift + P) → run: Shell Command: Install 'code' command in PATH
- Windows: Open VS Code → Command Palette (Ctrl + Shift + P) → run: Shell Command: Install 'code' command in PATH (by default the windows code command should work so you may not need to do this)

After installing the CLI, close and reopen any open terminals so the PATH change takes effect.

- Windows (PowerShell): `start_hellbender.ps1`

  - Location: repository root `start_hellbender.ps1`
  - Usage (from PowerShell in the repo):

    ```powershell
    # Example: default host and settings (requests 1 hour by default)
    .\start_hellbender.ps1

    # Example: request 20 minutes instead of 1 hour
    .\start_hellbender.ps1 -Time '0:20:00'
    ```

  - Notes: PowerShell execution policies may block scripts by default. You can run one-off with a bypass:
    ```powershell
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\start_hellbender.ps1
    ```
    or set a different Policy setting
    ```powershell
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    ```

- macOS / Linux (bash): `start_hellbender.sh`

  - Location: repository root (e.g. `start_hellbender.sh`)
  - Usage (from bash in the repo):

    ```bash
    # Change to the repository directory (replace with your actual path)
    cd /path/to/Modeling-Environment-Setup

    # Make the script executable and run it (requests 1 hour by default)
    chmod +x start_hellbender.sh
    ./start_hellbender.sh
    ```

Your session ends when:

- Your allocated time expires
- You cancel the job with `scancel <JOBID>`

## Using Slurm on Hellbender

For longer jobs or to schedule work, use Slurm batch scripts.

### Example Batch Script

Create `run_job.sh`:

```bash
#!/bin/bash
#SBATCH --partition=general          # Standard partition
#SBATCH --nodes=2                    # Number of nodes
#SBATCH --ntasks-per-node=32         # Cores per node
#SBATCH --job-name=my_sim            # Job name
#SBATCH --output=output_%j.txt       # Output file (%j = job ID)
#SBATCH --error=error_%j.txt         # Error file
#SBATCH --time=4:00:00               # Time limit (HH:MM:SS)
#SBATCH --mem=64G                    # Memory per node

# Load modules
module load gcc/12.2.1
module load intel_mpi

# Activate environment
source ~/.bashrc
conda activate NME

# Run simulation
cd $SLURM_SUBMIT_DIR
mpiexec -n $SLURM_NTASKS python run_network.py
```

### Submit and Monitor

**Submit job:**

```bash
sbatch run_job.sh
```

**Check status:**

```bash
squeue -u $USER
```

or

```bash
squeue --me
```

**Cancel job:**

```bash
scancel <JOBID>
```

**View job details:**

```bash
scontrol show job <JOBID>
```

## Best Practices

### Resource Management

**Start small:**

- Test with short time limits first
- Use single nodes for debugging
- Scale up after confirming everything works

**Be respectful:**

- Never run on login nodes
- Release nodes when done: `scancel <JOBID>`
- Use appropriate time limits

**Optimize allocation:**

- Request only what you need
- Multiple smaller jobs may allocate faster than one large job
- Interactive partition is good for development

### Efficient Development

**Local testing:**

- Test code thoroughly on local machines first
- Use small parameter sets for initial HPC tests
- Verify output files before large runs

**File organization:**

- Keep code in version control (Git)
- Use descriptive job names
- Clean up old output files regularly

## Common Issues

**"Connection refused" or can't connect:**

- Check that your SSH key is properly set up
- Ensure you allocated a compute node first

**"No space left on device":**

- Check your space: `du -sh .`
- Clean up old files
- Contact support if you need more space

**Job sits in queue (PD status):**

- System is busy; wait for resources
- Consider reducing resource requests
- Check if there are scheduled maintenance windows

**Module not found:**

- Use `module avail` to see available modules
- Module names may change; check Hellbender wiki for updates

**Permission denied errors:**

- Check file permissions: `ls -la`
- Scripts need execute permission: `chmod +x script.sh`

## Useful Commands Reference

```bash
# Check available modules
module avail

# Load a module
module load gcc/12.2.1

# See loaded modules
module list

# Check disk usage
du -sh DIR_PATH_TO_CHECK
```

## Additional Resources

- [Slurm Documentation](https://slurm.schedmd.com/documentation.html)
