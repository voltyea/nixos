#pragma once

#include <QObject>
#include <QtQml/qqml.h>
#include <QtDBus>

class ConnectionResult : public QObject {
  Q_OBJECT

  public:
    enum class Enum {
      None = 0,
      Unknown = 1,
      WrongPassword = 7
    };
    Q_ENUM(Enum)
};

class AccessPoint : public QObject {
  Q_OBJECT
    Q_PROPERTY(QString ssid READ ssid CONSTANT)
    Q_PROPERTY(int strength READ strength NOTIFY strengthChanged)
    Q_PROPERTY(bool active READ active NOTIFY activeChanged)
    Q_PROPERTY(bool saved READ saved NOTIFY savedChanged)
    Q_PROPERTY(int flags READ flags CONSTANT)
    Q_PROPERTY(int wpaFlags READ wpaFlags CONSTANT)
    Q_PROPERTY(int rsnFlags READ rsnFlags CONSTANT)
    QML_ELEMENT
    QML_UNCREATABLE("AccessPoint is an object for network")

  public:
    explicit AccessPoint(QObject *parent = nullptr);
    QString ssid() const;
    int strength() const;
    bool active() const;
    bool saved() const;
    bool open() const;
    int flags() const;
    int wpaFlags() const;
    int rsnFlags() const;
    QDBusObjectPath m_apPath;
    QDBusObjectPath m_devicePath;
    Q_INVOKABLE ConnectionResult::Enum connect(const QString &password);
    Q_INVOKABLE ConnectionResult::Enum connect();

signals:
    void strengthChanged();
    void activeChanged();
    void savedChanged();

    private slots:
      void onPropertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &invalidated) {
        if (interface == "org.freedesktop.NetworkManager.AccessPoint") {
          if (changed.contains("Strength")) {
            emit strengthChanged();
          }
        }
        if (interface == "org.freedesktop.NetworkManager.Device.Wireless") {
          if (changed.contains("ActiveAccessPoint")) {
            emit activeChanged();
          }
        }
        if (interface == "org.freedesktop.NetworkManager.Settings") {
          if (changed.contains("Connections")) {
            emit savedChanged();
          }
        }
      }
};

class Network : public QObject {
  Q_OBJECT
    Q_PROPERTY(QList<AccessPoint*> accessPoints READ accessPoints NOTIFY accessPointsChanged)
    QML_ELEMENT
    QML_SINGLETON

  public:
    explicit Network(QObject *parent = nullptr);
    QList<AccessPoint*> accessPoints();

  private:
    QList<QByteArray> m_savedSsids;
    QList<QString> m_activeApPaths;
    QList<AccessPoint*> m_result;
    void getAp();

signals:
    void accessPointsChanged();

    private slots:
      void onApChanged(const QDBusObjectPath &ap) {
        getAp();
      }
};
