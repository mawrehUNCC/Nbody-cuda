# CUDA N-Body Simulation

This program simulates gravitational interactions between particles using CUDA for GPU acceleration.

## Features
- Double-precision gravitational force calculation.
- Random initialization or load from `solar.tsv`.
- Configurable time step, number of steps, output frequency, and block size.
- Outputs simulation state to standard output in tab-separated format.

## Compile
```
make
```

## Run
```
./nbody <input: number|filename> <dt> <steps> <print_freq> <block_size>

Example:
./nbody 1000 0.01 10 1 128
```

## SLURM Job Submission
Submit to Centaurus GPU partition:
```
sbatch job.slurm
```

## File Format
Each line of output represents one simulation state:
```
<num_particles>\t<mass>\t<x>\t<y>\t<z>\t<vx>\t<vy>\t<vz>\t<fx>\t<fy>\t<fz> ...
```

## Notes
- All units are SI (kg, m, s).
- Uses softening factor to avoid singularities.
