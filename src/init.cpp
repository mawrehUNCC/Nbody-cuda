#include "particle.hpp"
#include <vector>
#include <random>
#include <fstream>
#include <sstream>

void randomInit(std::vector<Particle>& particles, int n) {
    std::default_random_engine eng;
    std::uniform_real_distribution<double> dist(-1e11, 1e11);
    std::uniform_real_distribution<double> mass_dist(1e20, 1e30);

    particles.resize(n);
    for (int i = 0; i < n; ++i) {
        particles[i].mass = mass_dist(eng);
        particles[i].position = make_double3(dist(eng), dist(eng), dist(eng));
        particles[i].velocity = make_double3(0, 0, 0);
        particles[i].force = make_double3(0, 0, 0);
    }
}

void loadFromFile(std::vector<Particle>& particles, const std::string& filename) {
    std::ifstream file(filename);
    std::string line;
    while (std::getline(file, line)) {
        std::stringstream ss(line);
        Particle p;
        ss >> p.mass >> p.position.x >> p.position.y >> p.position.z
           >> p.velocity.x >> p.velocity.y >> p.velocity.z;
        p.force = make_double3(0, 0, 0);
        particles.push_back(p);
    }
}