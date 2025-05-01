#ifndef PARTICLE_HPP
#define PARTICLE_HPP

#include <vector_types.h>

struct Particle {
    double mass;
    double3 position;
    double3 velocity;
    double3 force;
};

#ifndef __CUDACC__
inline double3 make_double3(double x, double y, double z) {
    double3 t; t.x = x; t.y = y; t.z = z;
    return t;
}
#endif // __CUDACC__

#endif // PARTICLE_HPP
