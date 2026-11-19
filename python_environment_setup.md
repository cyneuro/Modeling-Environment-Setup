# Modeling Environment Setup

This repository provides a step-by-step guide to set up a conda environment for neural modeling.

## Prerequisites

### Install Miniconda

First, download Miniconda:

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
```

Change the permissions to make the installer executable:

```bash
chmod +x Miniconda3-latest-Linux-x86_64.sh
```

Run the installer:

```bash
bash Miniconda3-latest-Linux-x86_64.sh
```

After installation, close any open terminals. If using SSH, close the window. If local, restart your computer.

## Environment Setup

### Create the Conda Environment

Create a new conda environment named `NME` (Neural Modeling Environment) with Python 3.12:

```bash
conda create -n NME python=3.12 -y
```

### Activate the Environment

Activate the environment:

```bash
conda activate NME
```

### Load Required Modules (HPC Systems)

Before installing packages, ensure GCC and MPI modules are loaded. This varies by HPC system.

For Hellbender:

```bash
module load openmpi/4.1.5_gcc_12.3.0
export MPI_HOME="$(dirname "$(dirname "$(command -v mpirun)")")"
export LD_LIBRARY_PATH="$MPI_HOME/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
```

On some Hellbender setups, loading OpenMPI adds its commands to `PATH` but does not let Python find `libmpi`. The exports above make that library available to `mpi4py`. Environment activation, module loading, and these exports apply to the current shell; repeat them in each new terminal or SSH session unless your personal shell startup already handles them.

For Expanse:

```bash
module purge
module load slurm
module load cpu/0.17.3b
module load gcc/10.2.0/npcyll4
module load openmpi/4.1.1
```

For lab server:

```bash
module load mpich-x86_64-nopy
```

For other systems, check available modules:

```bash
module avail
```

Look for modules with names like `openmpi`, `intel_mpi` or `mpich`.

## Package Installation

Install the required packages using pip:

I recommand running this command first and then the next pip command. I think this is the most stable neuron version.
```bash
pip install "setuptools==80.9.0" neuron==8.2.4
```

NEURON 8.2.4's `nrnivmodl` launcher imports `pkg_resources`. Pinning setuptools to 80.9.0 retains that module and avoids `ModuleNotFoundError: No module named 'pkg_resources'` with newer setuptools releases.

```bash
pip install jupyter pandas==2.3.3 mpi4py bmtk bmtool scipy seaborn
```

### Notes on Packages

- **BMTK**: The pip install may not always be the most up-to-date. For the latest version, install from [GitHub](https://github.com/AllenInstitute/bmtk).
- **BMTOOL**: If you plan to make changes to bmtool, install from the [repository](https://github.com/cyneuro/bmtool).

This setup provides a good starting point with all necessary packages for neural modeling.
