# Lab Server Quick Start Guide

This guide covers getting started with neural modeling on the lab server.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Access Methods](#access-methods)
  - [SSH Access via VS Code](#ssh-access-via-vs-code)
- [Environment Setup](./python_environment_setup.md)
- [Using Slurm on Lab Server](#using-slurm-on-lab-server)
- [Best Practices](#best-practices)
  - [Resource Management](#resource-management)
  - [Efficient Development](#efficient-development)
- [Additional Resources](#additional-resources)

## Prerequisites

- Dr. Nair needs to add you to the lab server.
- You must be on VPN or on campus to access the lab server.

## Access Methods

The first step is to log in to the lab server. Here is an example login command—replace `USERNAME` with your username and enter this in a terminal/command prompt:

```bash
ssh USERNAME@engr-nelvm-res.engineering.missouri.edu
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
Host lab
HostName engr-nelvm-res.engineering.missouri.edu
User USERNAME
MACs hmac-sha2-512
Port 22
```

#### Step 3: Copy SSH Key to Lab Server

**On Mac/Linux:**

```bash
ssh-copy-id USERNAME@engr-nelvm-res.engineering.missouri.edu
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
ssh-copy-id USERNAME@engr-nelvm-res.engineering.missouri.edu
```

## Environment Setup

For Python environment setup, Miniconda installation, conda environments, and package installations (including NEURON, BMTK, mpi4py), follow the [Python Environment Setup Guide](./python_environment_setup.md).

Before running Python scripts on the lab server, load the necessary module:

```bash
module load mpich-x86_64-nopy
```

## Using Slurm on Lab Server

The lab server uses Slurm for job scheduling. The only partition available is called "batch".

Here are some basic commands:

- Check queue status: `squeue`
- Submit a job: `sbatch job_script.sh`

### Example Batch Script

Create a file named `job.sh` with the following content (adjust as needed):

```bash
#!/bin/bash
#SBATCH --job-name=my_job
#SBATCH --output=my_job.out
#SBATCH --error=my_job.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --time=01:00:00
#SBATCH --partition=batch

# Load modules
module load mpich-x86_64-nopy

# Your commands here
echo "Running on $(hostname)"
python my_script.py
```

Submit with: `sbatch job.sh`

## Best Practices

### Resource Management

**Start small:**

- Test with short runs first
- Use appropriate resource limits
- Scale up after confirming everything works

**Be respectful:**

- Never run intensive jobs during peak hours
- Monitor resource usage
- Clean up after yourself

**Optimize usage:**

- Use the server efficiently
- Avoid unnecessary processes
- Share resources fairly

### Efficient Development

**Local testing:**

- Test code thoroughly on local machines first
- Use small parameter sets for initial tests
- Verify output files before large runs

**File organization:**

- Keep code in version control (Git)
- Use descriptive file names
- Clean up old output files regularly

## Additional Resources

- Contact Dr. Nair for server-specific questions
