#pragma once

#include <QObject>
#include <QtQml/qqml.h>

class Network : public QObject {
  Q_OBJECT
    Q_PROPERTY(bool wirelessEnabled READ wirelessEnabled NOTIFY wirelessEnabledChanged)
    QML_ELEMENT
    QML_SINGLETON

  public:
    Network(QObject *parent = nullptr);
    bool wirelessEnabled() const;

signals:
    void wirelessEnabledChanged();
};
