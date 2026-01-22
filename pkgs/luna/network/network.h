#pragma once

#include <QObject>
#include <QtQml/qqml.h>
#include <QtDBus>

class AccessPoint : public QObject {
  Q_OBJECT
    Q_PROPERTY(QString ssid READ ssid)
    Q_PROPERTY(int strength READ strength)
    Q_PROPERTY(bool active READ active)
    Q_PROPERTY(bool saved READ saved)
    Q_PROPERTY(bool open READ open)
    Q_PROPERTY(int flags READ flags)
    Q_PROPERTY(int wpaFlags READ wpaFlags)
    Q_PROPERTY(int rsnFlags READ rsnFlags)

  public:
    QString ssid() const;
    int strength() const;
    bool active() const;
    bool saved() const;
    bool open() const;
    int flags() const;
    int wpaFlags() const;
    int rsnFlags() const;

  private:
    QDBusObjectPath m_apPath;
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
    QSet<QByteArray> m_savedSsids;
    QSet<QString> m_activeApPaths;
    QList<AccessPoint*> m_result;

signals:
    void accessPointsChanged();
};
