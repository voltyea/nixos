#pragma once

#include <QObject>
#include <QtQml/qqml.h>
#include <QVariant>
#include <QString>
#include <NetworkManager.h>

struct AccessPointInfo {
  Q_GADGET
    Q_PROPERTY(QString ssid MEMBER ssid)
    Q_PROPERTY(int strength MEMBER strength)
    Q_PROPERTY(bool active MEMBER active)

  public:
    QString ssid;
    int strength = 0;
    bool active = false;
};
Q_DECLARE_METATYPE(AccessPointInfo)

  class Network : public QObject {
    Q_OBJECT
      Q_PROPERTY(bool active READ active WRITE setEnable NOTIFY activeChanged)
      Q_PROPERTY(QVariantList networks READ networks NOTIFY networksChanged)
      QML_ELEMENT
      QML_SINGLETON

    public:
      explicit Network(QObject* parent = nullptr);
      bool active() const;
      QVariantList networks() const;
      void setEnable(bool enabled);

Q_SIGNALS:
      void activeChanged();
      void networksChanged();
  };
