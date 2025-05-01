#!/bin/bash
#SBATCH --job-name=nbody_cuda
#SBATCH --partition=GPU
#SBATCH --time=00:10:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gres=gpu:1

./nbody 1000 0.01 10 1 128