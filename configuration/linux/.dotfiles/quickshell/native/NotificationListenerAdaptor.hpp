#pragma once

#include "NotificationListener.hpp"
#include <QDBusAbstractAdaptor>

class NotificationListenerAdaptor : public QDBusAbstractAdaptor {
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.freedesktop.Notifications")

  public:
    explicit NotificationListenerAdaptor(NotificationListener* parent);

  public slots:
    void CloseNotification(uint id);
    QStringList GetCapabilities();
    QString GetServerInformation(QString& vendor, QString& version, QString& specVersion);
    uint Notify(const QString& app_name, uint replaces_id, const QString& app_icon, const QString& summary, const QString& body,
                const QStringList& actions, const QVariantMap& hints, qint32 expire_timeout);
};
