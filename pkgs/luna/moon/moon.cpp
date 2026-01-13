#include "moon.h"
#include "lib/astro_demo_common.h"

Moon::Moon(QObject *parent) : QObject(parent) {
  startTimer(1h, QOverload<>::of(&Moon::phaseAngle));
}

double Moon::phaseAngle() const {
  return Astronomy_MoonPhase(Astronomy_CurrentTime()).angle;
}
