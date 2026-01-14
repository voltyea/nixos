#pragma once

#include <QObject>
#include <QtQml/qqml.h>
#include <QVector>
#include <QtDBus>

class Network : public QObject {
  Q_OBJECT
    Q_PROPERTY(bool wirelessEnabled READ wirelessEnabled NOTIFY wirelessEnabledChanged)
    Q_PROPERTY(QVector<QDBusObjectPath> accessPoints READ accessPoints NOTIFY accessPointsChanged)
    QML_ELEMENT
    QML_SINGLETON

  public:
    Network(QObject *parent = nullptr);
    bool wirelessEnabled() const;
    QVector<QDBusObjectPath> accessPoints() const;

signals:
    void wirelessEnabledChanged();
    void accessPointsChanged();

    private slots:
      void onPropertiesChanged(const QString &interface, const QVariantMap &changed, const QStringList &invalidated) {}

  private:
    QDBusInterface m_properties;

};
