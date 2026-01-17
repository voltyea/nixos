#pragma once

#include <QObject>
#include <QtQml/qqml.h>
#include <QtDBus>
#include <QList>
#include <QVariant>

class Network : public QObject {
  Q_OBJECT
    Q_PROPERTY(bool wirelessEnabled READ wirelessEnabled NOTIFY wirelessEnabledChanged)
    Q_PROPERTY(QList<AccessPoints> accessPoints READ accessPoints NOTIFY accessPointsChanged)
    QML_ELEMENT
    QML_SINGLETON

  public:
    explicit Network(QObject *parent = nullptr);
    bool wirelessEnabled() const;
    QList<AccessPoints> accessPoints() const;

signals:
    void wirelessEnabledChanged();
    void accessPointsChanged();

    private slots:
      void onApChanged(const QDBusObjectPath &ap);
    void onPropertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &invalidated);

  private:
    struct AccessPoints {
      QString ssid;
      int strength;
      bool active;
      bool saved;
      bool open;
    }
};
