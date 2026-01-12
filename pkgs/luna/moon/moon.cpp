#include "moon.h"
#include "lib/astro_demo_common.h"
#include <QTimer>

Moon::Moon(QObject *parent) : QObject(parent) {
  auto *timer = new QTimer(this);
  timer->setInterval(3600000);
  timer->setTimerType(Qt::CoarseTimer);
  connect(timer, &QTimer::timeout,
      this, &Moon::phaseAngleChanged);
  timer->start();
}
double Moon::phaseAngle() const {
  return Astronomy_MoonPhase(Astronomy_CurrentTime()).angle;
}
