#include "particle.hpp"
#include <vector>
#include <iostream>

void printState(const std::vector<Particle>& particles) {
    std::cout << particles.size();
    for (const auto& p : particles) {
        std::cout << "\t" << p.mass
                  << "\t" << p.position.x << "\t" << p.position.y << "\t" << p.position.z
                  << "\t" << p.velocity.x << "\t" << p.velocity.y << "\t" << p.velocity.z
                  << "\t" << p.force.x << "\t" << p.force.y << "\t" << p.force.z;
    }
    std::cout << "\n";
}