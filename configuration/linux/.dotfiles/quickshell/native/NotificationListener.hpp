#pragma once

#include <QDBusContext>
#include <QObject>
#include <QStringList>
#include <QVariantMap>
#include <QtQml>

class NotificationListener : public QObject, protected QDBusContext {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_CLASSINFO("D-Bus Interface", "org.freedesktop.Notifications")

  public:
    explicit NotificationListener(QObject* parent = nullptr);

  public slots:
    Q_SCRIPTABLE void CloseNotification(uint id);
    Q_SCRIPTABLE QStringList GetCapabilities();
    Q_SCRIPTABLE QStringList GetServerInformation();
    Q_SCRIPTABLE uint Notify(const QString& app_name, uint replaces_id, const QString& app_icon, const QString& summary, const QString& body,
                             const QStringList& actions, const QVariantMap& hints, qint32 expire_timeout);

  signals:
    void NotificationClosed(uint id, uint reason);
    void ActionInvoked(uint id, const QString& action_key);
    void notificationReceived(const QString& appName, const QString& icon, const QString& summary);

  private:
    void setupDbusConnection();
    uint nextId = 1;
};
