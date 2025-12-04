# Hellbender HPC Quick Start Guide

This guide covers getting started with neural modeling on Mizzou's Hellbender HPC system.

## Prerequisites

### Create Hellbender Account

Apply for an account through the [HPC Service Request Form](https://missouri.service-now.com/sp?id=sc_cat_item&sys_id=your_form_id).

**Before starting:**

- Understand basic HPC concepts: [Guide to HPC - Nodes and Processors](https://kinda-technical.com/hpc-guide)
- Review the [Hellbender Wiki](https://wiki.rnet.missouri.edu/confluence/display/HPCC/Hellbender)

## What You Can Do with Hellbender

By allocating multiple nodes, you can:

- Run large, intensive simulations (e.g., NEURON models with thousands of neurons) much faster
- Perform parameter sweeps where each node tests different values simultaneously
- Parallelize computations across many cores

## Access Methods

Hellbender can be accessed through a web interface or via SSH. Choose based on your needs:

| Method         | Best For                                           | Parallel Processing |
| -------------- | -------------------------------------------------- | ------------------- |
| OnDemand (Web) | Simple jobs, learning, single-node work            | Limited             |
| SSH (VS Code)  | Complex jobs, multi-node work, parallel processing | Full support        |

## Method 1: OnDemand Web Interface

Perfect for getting started quickly or running simple simulations.

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
├── .ssh/           # SSH configuration
└── data/           # Your working directory (use this!)
```

**Important:** All your code should be stored and run in the `data` folder.

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

**On Windows (run in PowerShell first, then use the command):**

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

#### Step 1: SSH into Hellbender

Open your terminal and connect:

```bash
ssh [your_pawprint]@hellbender-login.rnet.missouri.edu
```

Enter your SSH key passphrase when prompted. You should see a colorful "Welcome to Hellbender" message.

#### Step 2: Allocate a Compute Node

**Critical:** You are currently on a login node. **Never run computations here!** Running code on login nodes can crash the system and may result in account suspension.

Request a compute node:

```bash
salloc --time=1:00:00 --partition=interactive
```

This requests 1 node for 1 hour. Adjust as needed:

- Maximum time: 48 hours
- Longer requests may take longer to allocate
- Jobs may be preempted by paid subscriptions

**Wait for allocation.** The output will show: `nodes c### are ready for job`

Note your node ID (e.g., `c059`, `c123`).

#### Step 3: Check Your Nodes

View all your active nodes:

```bash
squeue -u [your_pawprint]
```

This shows:

- **Job ID:** Unique identifier for each job
- **Node ID(s):** Which nodes you're using (e.g., `c059`)
- **Time:** How long the job has been running
- **Status:** Current state (R = running, PD = pending)

#### Step 4: Connect to Your Node via VS Code

1. Open VS Code
2. Click the small icon in the **bottom-left corner**
3. Select "Connect to Host"
4. Type your node ID (e.g., `c059`)
5. Enter your SSH passphrase when prompted (may ask multiple times)

#### Step 5: Open Your Working Directory

1. Go to: File > Open Folder
2. Enter path: `/home/[your_pawprint]/data`
3. Click OK

You're now working on a compute node! You can:

- Clone repositories: `git clone ...`
- Run simulations: `python run_network.py`
- Use MPI: `mpiexec -n 4 python parallel_sim.py`

Your session ends when:

- Your allocated time expires
- You cancel the job with `scancel <JOBID>`

## Environment Setup

All installation and Python environment setup steps (Miniconda, conda env creation, package installation, NEURON, BMTK, mpi4py, CoreNEURON build notes) live in the consolidated guide `python_environment_setup.md`.

For Hellbender-specific module recommendations or examples, see the consolidated guide and, where needed, the Hellbender wiki.

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

- Verify you're on the MU network or VPN
- Check that your SSH key is properly set up
- Ensure you allocated a compute node first

**"No space left on device":**

- Check your quota: `quota -s`
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

- Make sure you're in your `data` directory
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
du -sh /home/[pawprint]/data

# Check your quota
quota -s

# Monitor resource usage
top
htop  # if available
```

## Additional Resources

- [Hellbender Wiki](https://wiki.rnet.missouri.edu/confluence/display/HPCC/Hellbender)
- [Hellbender Office Hours](https://calendly.com/hellbender-office-hours) - Get help from HPC staff
- [Slurm Documentation](https://slurm.schedmd.com/documentation.html)
- [MU HPC Support](mailto:hpc-support@missouri.edu)

## Getting Help

**Hellbender Office Hours:**

- Best for: General HPC questions, job optimization, troubleshooting
- Schedule via the wiki

**Lab Resources:**

- Check lab documentation for model-specific guidance
- Ask lab members about tested workflows

**Documentation:**

- Always check the Hellbender wiki first
- Module availability and names may change over time
