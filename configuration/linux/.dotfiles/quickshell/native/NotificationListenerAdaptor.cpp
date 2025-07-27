#include "NotificationListenerAdaptor.hpp"

NotificationListenerAdaptor::NotificationListenerAdaptor(NotificationListener* parent) : QDBusAbstractAdaptor(parent) {}

uint NotificationListenerAdaptor::Notify(const QString& app_name, uint replaces_id, const QString& app_icon, const QString& summary,
                                         const QString& body, const QStringList& actions, const QVariantMap& hints, qint32 expire_timeout) {
    return static_cast<NotificationListener*>(parent())->Notify(app_name, replaces_id, app_icon, summary, body, actions, hints, expire_timeout);
}

void NotificationListenerAdaptor::CloseNotification(uint id) {
    static_cast<NotificationListener*>(parent())->CloseNotification(id);
}

QStringList NotificationListenerAdaptor::GetCapabilities() {
    return static_cast<NotificationListener*>(parent())->GetCapabilities();
}

QString NotificationListenerAdaptor::GetServerInformation(QString& vendor, QString& version, QString& specVersion) {
    QStringList info = static_cast<NotificationListener*>(parent())->GetServerInformation();
    if (info.size() >= 4) {
        vendor = info[1];
        version = info[2];
        specVersion = info[3];
        return info[0];
    }

    vendor = "HyprShell";
    version = "1.0";
    specVersion = "1.0";
    return "HyprShell";
}
