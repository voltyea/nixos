#include "moon.h"
#include "lib/astro_demo_common.h"
#include <QTimer>

Moon::Moon(QObject *parent) : QObject(parent) {
  QTimer *timer = new QTimer(this);
  connect(timer, &QTimer::timeout, this, QOverload<>::of(&Moon::update));
  timer->start(1h);
}

double Moon::phaseAngle() const {
  return Astronomy_MoonPhase(Astronomy_CurrentTime()).angle;
}
