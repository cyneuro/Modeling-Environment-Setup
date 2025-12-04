# Expanse HPC Quick Start Guide

This guide covers getting started with neural modeling on SDSC's Expanse HPC system.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Access Methods](#access-methods)
  - [SSH Access via VS Code](#ssh-access-via-vs-code)
- [Environment Setup](./python_environment_setup.md)
- [Using Slurm on Expanse](#using-slurm-on-expanse)
- [Best Practices](#best-practices)
  - [Resource Management](#resource-management)
  - [Efficient Development](#efficient-development)
- [Additional Resources](#additional-resources)

## Prerequisites

Before you get started with Expanse, you need to make sure you have an ACCESS account. That can be made here: https://access-ci.org/. You will then need to be added to the lab's allocation on ACCESS.

You also need to set up two-factor authentication (2FA) with Expanse, which can be done here: https://passive.sdsc.edu/. See the section "2FA with Authenticator (Required)" on this site for more details: https://www.sdsc.edu/systems/expanse/user_guide.html.

## Access Methods

The first step is to log in to Expanse. Here is an example login command—replace `USERNAME` with your ACCESS username and enter this in a terminal/command prompt:

```bash
ssh USERNAME@login.expanse.sdsc.edu
```

### SSH Access via VS Code

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
Host expanse
HostName login.expanse.sdsc.edu
User USERNAME
Port 22
MACs hmac-sha2-512
```

#### Step 3: Copy SSH Key to Expanse

**On Mac/Linux:**

```bash
ssh-copy-id USERNAME@login.expanse.sdsc.edu
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
ssh-copy-id USERNAME@login.expanse.sdsc.edu
```

## Environment Setup

For Python environment setup, Miniconda installation, conda environments, and package installations (including NEURON, BMTK, mpi4py), follow the [Python Environment Setup Guide](./python_environment_setup.md).

Before running Python scripts or jobs, load the necessary modules on Expanse:

```bash
module purge
module load slurm
module load cpu/0.17.3b
module load gcc/10.2.0/npcyll4
module load openmpi/4.1.1
```

## Using Slurm on Expanse

Expanse uses Slurm for job scheduling. Here are some basic commands:

- Check queue status: `squeue`
- Submit a job: `sbatch job_script.sh`
- Check job status: `sacct`

All jobs on Expanse require an account directive to specify which allocation to charge. Use `#SBATCH --account=umc113` for the lab's current allocation. This is how Expanse knows whose account to charge—do not change this unless a new allocation is obtained.

Jobs also require a partition directive. Use `#SBATCH --partition=shared` for jobs using fewer than 128 cores to minimize queue time. Use `#SBATCH --partition=compute` for jobs requiring more than 128 cores.

### Example Batch Script

Create a file named `job.sh` with the following content (adjust as needed):

```bash
#!/bin/bash
#SBATCH --job-name=my_job
#SBATCH --output=my_job.out
#SBATCH --error=my_job.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=01:00:00
#SBATCH --partition=shared
#SBATCH --account=umc113

# Load modules
module purge
module load slurm
module load cpu/0.17.3b
module load gcc/10.2.0/npcyll4
module load openmpi/4.1.1

# Your commands here
echo "Running on $(hostname)"
python my_script.py
```

Submit with: `sbatch job.sh`

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
- Shared partition is good for development (fewer than 128 cores)

### Efficient Development

**Local testing:**

- Test code thoroughly on local machines first
- Use small parameter sets for initial HPC tests
- Verify output files before large runs

**File organization:**

- Keep code in version control (Git)
- Use descriptive job names
- Clean up old output files regularly

## Additional Resources

- [Expanse User Guide](https://www.sdsc.edu/systems/expanse/user_guide.html)
- [ACCESS Documentation](https://access-ci.org/)
