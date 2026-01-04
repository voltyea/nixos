#include "moon.h"
#include "lib/astro_demo_common.h"

Moon::Moon(QObject *parent)
  : QObject(parent)
{
}
double Moon::phaseAngle() const
{
  return Astronomy_MoonPhase(Astronomy_CurrentTime()).angle;
}
