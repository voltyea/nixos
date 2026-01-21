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
    int strength;
    bool active;
    bool saved;
    bool open;
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
      QList<AccessPoint> accessPoints() const;

    private:
      QList<AccessPoint> m_result;
      QSet<QString> m_activeApPaths;
      QSet<QByteArray> m_savedSsids;
      uint m_flags;
      uint m_wpaflags;
      uint m_rsnflags;

signals:
      void accessPointsChanged();
  };
