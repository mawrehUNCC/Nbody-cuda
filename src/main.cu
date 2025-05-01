#include "particle.hpp"
#include <iostream>
#include <vector>
#include <cmath>
#include <cuda_runtime.h>
#include <fstream>
#include <iomanip>

#define G 6.674e-11
#define SOFTENING 1e-9

__device__ double3 operator+(double3 a, double3 b) {
    return make_double3(a.x + b.x, a.y + b.y, a.z + b.z);
}

__device__ double3 operator-(double3 a, double3 b) {
    return make_double3(a.x - b.x, a.y - b.y, a.z - b.z);
}

__device__ double3 operator*(double a, double3 b) {
    return make_double3(a * b.x, a * b.y, a * b.z);
}

__device__ double3 operator/(double3 a, double b) {
    return make_double3(a.x / b, a.y / b, a.z / b);
}

__device__ double norm(double3 a) {
    return sqrt(a.x * a.x + a.y * a.y + a.z * a.z + SOFTENING);
}

__global__ void computeForces(Particle* particles, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= n) return;
    double3 force = make_double3(0, 0, 0);
    for (int j = 0; j < n; ++j) {
        if (i == j) continue;
        double3 r = particles[j].position - particles[i].position;
        double dist = norm(r);
        force = force + (G * particles[i].mass * particles[j].mass / (dist * dist * dist)) * r;
    }
    particles[i].force = force;
}

__global__ void updateParticles(Particle* particles, int n, double dt) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= n) return;
    double3 acceleration = particles[i].force / particles[i].mass;
    particles[i].velocity = particles[i].velocity + dt * acceleration;
    particles[i].position = particles[i].position + dt * particles[i].velocity;
}

extern void randomInit(std::vector<Particle>&, int);
extern void loadFromFile(std::vector<Particle>&, const std::string&);
extern void printState(const std::vector<Particle>&);

int main(int argc, char** argv) {
    if (argc < 6) {
        std::cerr << "Usage: " << argv[0] << " <input: number|filename> <dt> <steps> <print_freq> <block_size>\n";
        return 1;
    }

    std::vector<Particle> particles;
    int n;
    std::string arg = argv[1];
    if (isdigit(arg[0])) {
        n = std::stoi(arg);
        randomInit(particles, n);
    } else {
        loadFromFile(particles, arg);
        n = particles.size();
    }

    double dt = std::stod(argv[2]);
    int steps = std::stoi(argv[3]);
    int print_freq = std::stoi(argv[4]);
    int block_size = std::stoi(argv[5]);

    // Create output file for logging
    std::ofstream log_file("nbody_output.tsv");
    log_file << "Timestep\tIndex\tMass\t\tX\t\tY\t\tZ\t\tVx\t\tVy\t\tVz\n";

    Particle* d_particles;
    cudaMalloc(&d_particles, n * sizeof(Particle));
    cudaMemcpy(d_particles, particles.data(), n * sizeof(Particle), cudaMemcpyHostToDevice);

    int grid_size = (n + block_size - 1) / block_size;

    for (int step = 0; step < steps; ++step) {
        computeForces<<<grid_size, block_size>>>(d_particles, n);
        updateParticles<<<grid_size, block_size>>>(d_particles, n, dt);

        if (step % print_freq == 0) {
            cudaMemcpy(particles.data(), d_particles, n * sizeof(Particle), cudaMemcpyDeviceToHost);

            // Print to console for debugging
            std::cout << "Timestep: " << step << std::endl;
            std::cout << "Index\tMass\t\tX\t\tY\t\tZ\t\tVx\t\tVy\t\tVz\n";

            int print_limit = std::min(n, 10);  // Limit output to first 10 particles

            for (int i = 0; i < print_limit; ++i) {
                std::cout << i << "\t"
                          << particles[i].mass << "\t"
                          << particles[i].position.x << "\t"
                          << particles[i].position.y << "\t"
                          << particles[i].position.z << "\t"
                          << particles[i].velocity.x << "\t"
                          << particles[i].velocity.y << "\t"
                          << particles[i].velocity.z << std::endl;

                // Log to file in tab-separated format
                log_file << step << "\t" 
                         << i << "\t" 
                         << particles[i].mass << "\t"
                         << particles[i].position.x << "\t"
                         << particles[i].position.y << "\t"
                         << particles[i].position.z << "\t"
                         << particles[i].velocity.x << "\t"
                         << particles[i].velocity.y << "\t"
                         << particles[i].velocity.z << "\n";
            }
            std::cout << std::endl;
        }
    }

    cudaFree(d_particles);
    log_file.close();  // Close the log file

    return 0;
}
