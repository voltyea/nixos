#pragma once

#include <QObject>
#include <QtQml/qqml.h>

class Network : public QObject {
  Q_OBJECT
    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged)
    QML_ELEMENT
    QML_SINGLETON

  public:
    explicit Network(QObject *parent = nullptr);
    bool enabled() const;

signals:
    void enabledChanged();
};
