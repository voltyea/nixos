#pragma once

#include <QObject>
#include <QtQml/qqml.h>

class Moon : public QObject {
  Q_OBJECT
  Q_PROPERTY(double phaseAngle READ phaseAngle NOTIFY phaseAngleChanged)
  QML_ELEMENT
  QML_SINGLETON

public:
  double phaseAngle() const;

signals:
  void phaseAngleChanged();

private slots:
  void updatePhaseAngle();

private:
  double m_phaseAngle = 0.0;
};
