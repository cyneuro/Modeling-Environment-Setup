# Modeling-Environment-Setup
## This is a list of commands that should be ran in order to set up a conda environment 

### First download miniconda
```
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh 
```
### Then change the permissions in order to run the installer
```
chmod +x Miniconda3-latest-Linux-x86_64.sh 
```
### Then run the installer
```
bash Miniconda3-latest-Linux-x86_64.sh 
```
### Then close out of any terminal you have open. If you are doing this over SSH then close the window. If local then restart computer. Then we will download the evironment file. If this command fails you can download the environmnet.yml file that is in this repo. It is the same file! Just make sure the file is in your working directory when running the next command.
```
curl -OL https://raw.githubusercontent.com/cyneuro/Modeling-Environment-Setup/refs/heads/main/environment.yml
```
### Now we will create the conda environment
``` 
conda env create -f environment.yml
```
### Now you will be able to activate the anaconda environment using the command (NME stands for Neural Modeling Environment)
``` 
conda activate NME
``` 
### Some packages do not install using Conda, so we will use pip to finish the install process.

### This line is only needed if you plan on doing runs in parallel. You should have a version of mpi loaded before install for example mpich or openmpi. On most HPC devices you can see modules with module avail
```
pip install mpi4py-mpich
```
### Neuron will soon be switching over to version 9.0 and some files won't work correctly in this version. It may be best to use the 8.2.4 version.
```
pip install neuron==8.2.4
```
### The pip install of BMTK is not always the most up to date. If you think you need the most up to date version you can install from their [GitHub](https://github.com/AllenInstitute/bmtk)
``` 
pip install bmtk
```
### Then we will install BMTOOL
``` 
pip install bmtool
``` 
### This should be a good starting point and have every package someone needs to get started with neural modeling. 
