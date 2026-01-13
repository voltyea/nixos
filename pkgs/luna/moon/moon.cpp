#include "moon.h"
#include "lib/astro_demo_common.h"
#include <QTimer>

Moon::Moon(QObject *parent) : QObject(parent) {
  QTimer *timer = new QTimer(this);
  connect(timer, &QTimer::timeout, this, &Moon::phaseAngle);
    timer->setInterval(3600000);
    timer->start();
}

double Moon::phaseAngle() const {
  return Astronomy_MoonPhase(Astronomy_CurrentTime()).angle;
}
