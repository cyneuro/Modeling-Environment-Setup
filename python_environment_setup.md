# Python Environment Setup for Neural Modeling

This document consolidates all Python environment and package setup instructions for this repository. If you need to install Miniconda, create or activate the conda environment, or install core packages (NEURON, BMTK, mpi4py, etc.), this is the single authoritative guide.

## Table of contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Install Miniconda](#install-miniconda)
- [Create & activate environment](#create--activate-environment)
- [HPC module notes](#hpc-module-notes)
- [Core packages to install](#core-packages-to-install)
- [MPI support (mpi4py)](#mpi-support-mpi4py)
- [NEURON installation](#neuron-installation)
- [BMTK and BMTOOL](#bmtk-and-bmtool)
- [CoreNEURON (optional)](#coreneuron-optional)
  - [CPU builds](#coreneuron-cpu-build)
  - [GPU builds](#coreneuron-gpu-build)
- [Verification and tests](#verification-and-tests)
- [Troubleshooting](#troubleshooting)
- [Links and references](#links-and-references)

---

## Overview

This file centralizes everything related to setting up Python and relevant scientific packages needed for neural modeling. The other guides in this repository (for specific HPC systems and workflows) no longer contain installation steps — they point here.

## Prerequisites

- A supported Unix-like OS environment (Linux/macOS) or shell access to an HPC login node
- Working SSH and git credentials for cloning repos
- (Optional) Access to an HPC system where you may need to load modules before building or installing certain packages

## Install Miniconda

Download the Miniconda installer for your platform and run it. Example for Linux:

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
```

After install, either close/reopen your terminal or `source ~/.bashrc` / `source ~/.zshrc` to refresh shell paths.

## Create & activate environment

Create a reproducible environment named `NME` (Neural Modeling Environment) and activate it:

```bash
conda create -n NME python=3.12 -y
conda activate NME
```

If your system limits Python versions (HPC), consider `python=3.10` or `3.9` — check with your system documentation.

## HPC module notes

On some HPC systems, compilers and MPI libraries are managed via `module` commands. Load the recommended modules for your cluster BEFORE installing packages that need compiled extensions (mpi4py, NEURON, CoreNEURON).

Example (Hellbender):

```bash
module load gcc/12.2.1
module load intel_mpi
```

If unsure, run `module avail` and ask your sysadmins which modules to use.

## Core packages to install

Install the most common packages used across the repository. Prefer `pip` inside the conda env when using wheels or prebuilt binaries. Use `conda` as a fallback if compilation fails.

```bash
pip install jupyter pandas scipy seaborn h5py
```

### Optional tools

- `bmtk` — neural model building toolkit
- `bmtool` — visualization/analysis helper maintained in this organization

Install them with `pip`, or if you want the latest development version, install from the GitHub repo.

## MPI support (mpi4py)

MPI bindings are required for parallel simulations. Typical options:

1. Pip - most systems:

```bash
pip install mpi4py
```

2. Conda (useful on some HPC systems where the compiler / MPI ABI matters):

```bash
conda install -c conda-forge mpi4py openmpi
```

If MPI installation fails with pip, switch to the conda approach and ensure module environment is set.

## NEURON installation

NEURON is a widely used simulator. Most users can install from pip for stable releases:

```bash
pip install neuron==8.2.4
# or use the nightly if you need bleeding-edge features
pip install neuron-nightly
```

Building legacy NEURON versions or special builds should be done only if you require them; follow the upstream `NEURON` docs when needed.

## BMTK and BMTOOL

To install BMTK (quick):

```bash
pip install bmtk
```

To install BMTOOL:

```bash
pip install bmtool
```

For development installs, clone the repository and `pip install -e .` or `python setup.py install` inside the repo.

## CoreNEURON (optional, advanced)

CoreNEURON is an optimized engine for NEURON. Building and using CoreNEURON usually requires appropriate compilers and MPI. See the original NEURON/CoreNEURON docs for details — this repo includes examples when needed.

### CoreNEURON - CPU builds

Load compilers / MPI modules, then configure and build with CMake, enabling CORENEURON flags.

### CoreNEURON - GPU builds

GPU builds require vendor compilers and CUDA toolchains; only use GPU-specific build guidance for production needs.

## Verification and tests

Basic tests after installation:

```bash
python -c "import neuron; print('NEURON version:', getattr(neuron, '__version__', 'unknown'))"
python -c "import bmtk; print('BMTK imported')"
python -c "from mpi4py import MPI; print('MPI Rank:', MPI.COMM_WORLD.Get_rank())"
```

## Troubleshooting

- Conda not found after installation: restart your shell or log out and back in
- mpi4py build errors: try installing MPI via `module` or switch to `conda install -c conda-forge mpi4py openmpi`
- NEURON import issues: check python version and that your PATH / PYTHONPATH points to the correct install

## Links and references

- NEURON docs: https://neuron.yale.edu
- BMTK: https://github.com/AllenInstitute/bmtk
- BMTOOL: https://github.com/cyneuro/bmtool

If you find anything missing or have system-specific instructions that should be added, please open an issue or submit a PR to update this guide.
