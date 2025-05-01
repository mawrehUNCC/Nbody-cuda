#ifndef PARTICLE_HPP
#define PARTICLE_HPP

#include <vector_types.h>

struct Particle {
    double mass;
    double3 position;
    double3 velocity;
    double3 force;
};

#endif