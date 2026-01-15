#pragma once

#include <QObject>
#include <QtQml/qqml.h>
#include <QtQml/QQmlListProperty>
#include <QtDBus>
#include <QList>
#include <QSet>

/* ================= AccessPoint ================= */

class AccessPoint : public QObject {
  Q_OBJECT
    Q_PROPERTY(QString ssid READ ssid CONSTANT)
    Q_PROPERTY(uint strength READ strength CONSTANT)
    Q_PROPERTY(bool active READ active CONSTANT)
    Q_PROPERTY(bool open READ open CONSTANT)
    Q_PROPERTY(bool saved READ saved CONSTANT)

  public:
    explicit AccessPoint(QObject *parent = nullptr);

    QString ssid() const;
    uint strength() const;
    bool active() const;
    bool open() const;
    bool saved() const;

    void setData(const QString &ssid,
        uint strength,
        bool active,
        bool open,
        bool saved,
        const QDBusObjectPath &apPath,
        const QDBusObjectPath &devicePath);

    Q_INVOKABLE void connect(const QString &password = QString());
    Q_INVOKABLE void disconnect();

  private:
    QString m_ssid;
    uint m_strength = 0;
    bool m_active = false;
    bool m_open = false;
    bool m_saved = false;

    QDBusObjectPath m_apPath;
    QDBusObjectPath m_devicePath;
};

/* ================= Network ================= */

class Network : public QObject {
  Q_OBJECT
    Q_PROPERTY(bool wirelessEnabled READ wirelessEnabled NOTIFY wirelessEnabledChanged)
    Q_PROPERTY(QQmlListProperty<QObject> accessPoints READ accessPoints NOTIFY accessPointsChanged)

    QML_ELEMENT
    QML_SINGLETON

  public:
    explicit Network(QObject *parent = nullptr);

    bool wirelessEnabled() const;
    QQmlListProperty<QObject> accessPoints();

signals:
    void wirelessEnabledChanged();
    void accessPointsChanged();

    private slots:
      void onPropertiesChanged(const QString &interface,
          const QVariantMap &changed,
          const QStringList &invalidated);

  private:
    QList<QObject*> m_accessPoints;
    QSet<QString> m_savedSsids;

    // QQmlListProperty helpers
    static qsizetype apCount(QQmlListProperty<QObject>* p);
    static QObject* apAt(QQmlListProperty<QObject>* p, qsizetype index);

    void reloadAsync();
    void fetchSavedConnections();
    void fetchDevices();
    void fetchAccessPoints(const QDBusObjectPath &device,
        const QDBusObjectPath &activeAp);
};
