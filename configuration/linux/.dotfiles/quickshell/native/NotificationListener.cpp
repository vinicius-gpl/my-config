#include "NotificationListener.hpp"
#include "NotificationListenerAdaptor.hpp"

#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDebug>

NotificationListener::NotificationListener(QObject* parent) : QObject(parent) {
    setupDbusConnection();
}

void NotificationListener::setupDbusConnection() {
    QDBusConnection dBus = QDBusConnection::sessionBus();
    if (!dBus.isConnected()) {
        qFatal() << "Cannot connect to D-Bus session bus";
        return;
    }

    QDBusConnectionInterface* dBusInterface = dBus.interface();
    if (!dBusInterface->registerService("org.freedesktop.Notifications", QDBusConnectionInterface::ReplaceExistingService,
                                        QDBusConnectionInterface::DontAllowReplacement)) {
        qFatal() << "Failed to register D-Bus service";
        return;
    }

    // Use the NotificationListenerAdaptor to handle D-Bus requests
    new NotificationListenerAdaptor(this);
    if (!dBus.registerObject("/org/freedesktop/Notifications", this,
                             QDBusConnection::ExportAdaptors | QDBusConnection::ExportAllSlots | QDBusConnection::ExportAllSignals)) {
        qFatal() << "Failed to register D-Bus object";
        return;
    }

    qDebug() << "Registered org.freedesktop.Notifications";
}

uint NotificationListener::Notify(const QString& app_name, uint replaces_id, const QString& app_icon, const QString& summary, const QString& body,
                                  const QStringList& actions, const QVariantMap& hints, qint32 expire_timeout) {
    uint id = replaces_id > 0 ? replaces_id : nextId++;
    emit notificationReceived(app_name, app_icon, summary);

    qDebug() << "Notify:" << app_name << id << app_icon << summary << body << actions << hints << expire_timeout;
    return id;
}

void NotificationListener::CloseNotification(uint id) {
    qDebug() << "Closing notification:" << id;
    emit NotificationClosed(id, 3);
}

QStringList NotificationListener::GetCapabilities() {
    return {"body", "actions", "icon-static", "persistence"};
}

QStringList NotificationListener::GetServerInformation() {
    return {"HyprShell", "HyprShell", "1.0", "1.0"};
}
