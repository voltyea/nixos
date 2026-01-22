#pragma once

#include <QObject>
#include <QtQml/qqml.h>
#include <QtDBus>

struct AccessPoint {
  Q_GADGET
    Q_PROPERTY(QString ssid MEMBER ssid)
    Q_PROPERTY(int strength MEMBER strength)
    Q_PROPERTY(bool active MEMBER active)
    Q_PROPERTY(bool saved MEMBER saved)
    Q_PROPERTY(bool open MEMBER open)

  public:
    QString ssid;
    int strength = 0;
    bool active = false;
    bool saved = false;
    bool open = false;
};
  Q_DECLARE_METATYPE(AccessPoint)
Q_DECLARE_METATYPE(QList<AccessPoint>)

  class Network : public QObject {
    Q_OBJECT
      Q_PROPERTY(QList<AccessPoint> accessPoints READ accessPoints NOTIFY accessPointsChanged)
      QML_ELEMENT
      QML_SINGLETON

    public:
      explicit Network(QObject *parent = nullptr);
      QList<AccessPoint> accessPoints();

signals:
      void accessPointsChanged();
  };
