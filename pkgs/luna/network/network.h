#pragma once

#include <QObject>
#include <QtQml/qqml.h>
#include <QList>

struct AccessPointInfo {
  Q_GADGET
    Q_PROPERTY(int strength MEMBER strength)
    Q_PROPERTY(bool active MEMBER active)
  public:
    int strength;
    bool active;
};
Q_DECLARE_METATYPE(AccessPointInfo)

  class Network : public QObject
{
  Q_OBJECT
    Q_PROPERTY(bool active READ active NOTIFY activeChanged)
    Q_PROPERTY(QList<AccessPointInfo> networks READ networks NOTIFY networksChanged)
    QML_ELEMENT
    QML_SINGLETON

  public:
    explicit Network(QObject *parent = nullptr);
    bool active() const;
    QList<AccessPointInfo> networks() const;

Q_SIGNALS:
    void activeChanged();
    void networksChanged();
};
