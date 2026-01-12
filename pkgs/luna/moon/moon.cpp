#include "moon.h"
#include "lib/astro_demo_common.h"
#include <QTimer>

Moon::Moon(QObject *parent) : QObject(parent) {
    auto *timer = new QTimer(this);
    timer->setInterval(3600000);
    timer->setTimerType(Qt::CoarseTimer);
    connect(timer, &QTimer::timeout,
            this, &Moon::updatePhaseAngle);
    timer->start();
    updatePhaseAngle();
}

double Moon::phaseAngle() const {
    return m_phaseAngle;
}

void Moon::updatePhaseAngle() {
    const double newValue = Astronomy_MoonPhase(Astronomy_CurrentTime()).angle;

    if (qFuzzyCompare(m_phaseAngle, newValue))
        return;

    m_phaseAngle = newValue;
    emit phaseAngleChanged();
}
