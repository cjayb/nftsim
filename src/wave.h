/**
 * @file wave.h
 * @brief Wave propagator definition
 *
 * The wave propagator definition, inlcuding parameters from the wave equation
 * and coefficients related to the nine-point stencil implementation.
 *
 *
 * @author Peter Drysdale, Felix Fung, Romesh Abeysuriya, Paula Sanz-Leon,
 *
 */

#ifndef NEUROFIELD_SRC_WAVE_H
#define NEUROFIELD_SRC_WAVE_H

// Other neurofield headers
#include "configf.h"    // Configf;
#include "population.h" // Population;
#include "propagator.h" // Propagator;
#include "stencil.h"    // Stencil;

// C++ standard library headers
#include <string>  // std::string

class Wave : public Propagator {
  Wave(); // no default constructor
  Wave(Wave&); // no copy constructor
 protected:
  void init( Configf& configf ) override;
  //void restart( Restartf& restartf );
  //void dump( Dumpf& dumpf ) const;

  Stencil* oldp[2]; ///< keyring stencil to past phi, oldp[key]==most recent
  Stencil* oldQ[2]; ///< keyring stencil to past Q, oldQ[key]==most recent
  int key;          ///< used as an index into a length 2 cyclical history of phi and Q.

  // variables that are initialized once only
  double deltax;      ///< Grid spacing in space - spatial resolution
  double dt2on12;
  double dfact;
  double dt2ondx2;    ///< Factor in wave equation equal to ((gamma deltat)^2)/12.
  double p2;          ///< Dimensionless step-size squared. Square of the mesh ratio.
  double tenminus4p2; ///< Factor in wave algorithm
  double twominus4p2; ///< Factor in wave algorithm
  double expfactneg;  ///< Exp(- gamma deltat) - invert substitutions \f$u={\phi}e^{\gamma t}\f$; \f$w=Q e^{\gamma t}\f$.
  double expfactpos;  ///< Exp(gamma deltat) - invert substitutions \f$u={\phi}e^{\gamma t}\f$; \f$w=Q e^{\gamma t}\f$.

  // variables that are changed every timestep
  double sump;     ///< sum of the points in the von Neumann neighbourhood (phi)
  double sumQ;     ///< sum of the points in the von Neumann neighbourhood (Q)
  double drive;
 public:
  Wave( size_type nodes, double deltat, size_type index, Population& prepop,
        Population& postpop, int longside, std::string topology );
  ~Wave(void) override;
  void step(void) override;
};

#endif //NEUROFIELD_SRC_WAVE_H
