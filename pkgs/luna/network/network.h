#pragma once

#include <QObject>
#include <QtQml/qqml.h>
#include <QtDBus>
#include <QVector>
#include <QVariant>
#include <QSet>

class AccessPoint : public QObject {
  Q_OBJECT
    Q_PROPERTY(QString ssid READ ssid CONSTANT)
    Q_PROPERTY(uint strength READ strength CONSTANT)
    Q_PROPERTY(bool active READ active CONSTANT)
    Q_PROPERTY(bool open READ open CONSTANT)
    Q_PROPERTY(bool saved READ saved CONSTANT)

  public:
    explicit AccessPoint(QObject *parent = nullptr) : QObject(parent) {}
    QString ssid() const {return m_ssid;}
    uint strength() const {return m_strength;}
    bool active() const {return m_active;}
    bool open() const {return m_open;}
    bool saved() const {return m_saved;}
    Q_INVOKABLE void connect(const QString &password = QString());
    Q_INVOKABLE void disconnect();
    QString m_ssid;
    uint m_strength = 0;
    bool m_active = false;
    bool m_open = false;
    bool m_saved = false;
    QDBusObjectPath m_apPath;
    QDBusObjectPath m_devicePath;
};

class Network : public QObject {
  Q_OBJECT
    Q_PROPERTY(bool wirelessEnabled READ wirelessEnabled NOTIFY wirelessEnabledChanged)
    Q_PROPERTY(QVariantList accessPoints READ accessPoints NOTIFY accessPointsChanged)
    QML_ELEMENT
    QML_SINGLETON

  public:
    explicit Network(QObject *parent = nullptr);
    bool wirelessEnabled() const;
    QVariantList accessPoints() const;

signals:
    void wirelessEnabledChanged();
    void accessPointsChanged();

    private slots:
      void onApAdded(const QDBusObjectPath &ap);
    void onApRemoved(const QDBusObjectPath &ap);
    void onDbusPropertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &invalidated);
    void onPropertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &invalidated);

  private:
    QVector<AccessPoint*> m_accessPoints;
    QSet<QString> m_savedSsids;
    void reloadAsync();
    void fetchSavedConnections();
    void fetchDevices();
    void fetchAccessPoints(const QDBusObjectPath &device, const QDBusObjectPath &activeAp);
};
