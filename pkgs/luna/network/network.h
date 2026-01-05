#pragma once

#include <QObject>
#include <QtQml/qqml.h>
#include <QVariant>
#include <QString>
#include <NetworkManager.h>

class AccessPoint : public QObject {
  Q_OBJECT
    Q_PROPERTY(QString ssid READ ssid CONSTANT)
    Q_PROPERTY(int strength READ strength CONSTANT)
    Q_PROPERTY(bool active READ active CONSTANT)

  public:
    AccessPoint(
        NMDeviceWifi *wifi,
        NMAccessPoint *ap,
        bool isActive,
        QObject *parent = nullptr
        );

    QString ssid() const;
    int strength() const;
    bool active() const;

    Q_INVOKABLE void connect(const QString &password);
    Q_INVOKABLE void disconnect();

  private:
    NMDeviceWifi *m_wifi;
    NMAccessPoint *m_ap;
    bool m_active;
};

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
