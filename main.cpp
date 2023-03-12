#include <QGuiApplication>
#include <QQuickView>
#include <QDebug>

#include <nemonotifications-qt5/notification.h>
#include "src/controller.h"
#include "src/resourcehandler.h"

#include <sailfishapp.h>

quint32 m_notificationId = 0;

void showNotification(QString body, QString summary) {
    qWarning() << Q_FUNC_INFO;

    Notification n;
    n.setReplacesId(m_notificationId);
    n.setPreviewBody(body);
    n.setPreviewSummary(summary);
    n.publish();
    m_notificationId = n.replacesId();
}

void removeNotification() {
    if (m_notificationId == 0) {
        return;
    }

    Notification n;
    n.setReplacesId(m_notificationId);
    n.close();

    m_notificationId = 0;
}

void stopMPD() {
    QProcess process;
    QString exitMessage = "";
    process.start("/usr/bin/systemctl", QStringList() << "--user"
                                                      << "is-active"
                                                      << "mpd");
    process.waitForFinished(-1);
    if (process.exitCode() == 0) {
        qDebug() << "Stopping MPD ";
        process.start("/usr/bin/systemctl", QStringList() << "--user"
                                                          << "stop"
                                                          << "mpd");
        exitMessage = "Stopped MPD service";
        process.waitForFinished(-1);
    }
    if (!exitMessage.isEmpty()) {
        removeNotification();
        showNotification(exitMessage, "");
    }
    exit(0);
}

QString mkdir(QString path, QString name)
{
    QDir dir(path);
    QDir rmdir(path + "/" + name);

    rmdir.removeRecursively();
    if (!dir.mkdir(name)) {
        QFileInfo info(path);
        if (!info.isWritable())
            return QString("No permissions to create %1").arg(name);

        return QString("Cannot create folder %1").arg(name);
    }

    return QString();
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setOrganizationName("harbour-smpc");
    app->setApplicationName("harbour-smpc");
    ResourceHandler *resourceHandler = new ResourceHandler();

    QLocale::setDefault(QLocale::c());
    QQuickView *view = SailfishApp::createView();
    view->engine()->addImportPath("/usr/share/harbour-smpc/qml/");
    view->setSource(SailfishApp::pathTo("qml/main.qml"));
    view->setDefaultAlphaBuffer(true);
    view->rootContext()->setContextProperty("version", APP_VERSION);
    view->rootContext()->setContextProperty("buildyear", BUILD_YEAR);
    view->rootContext()->setContextProperty(QLatin1String("resourceHandler"), resourceHandler);

    foreach(QString path, view->engine()->importPathList()) {
        qDebug() << path;
    }

    mkdir("/tmp", "harbour-smpc");
    QSettings mySets;
    int stopMPDOnExit = mySets.value("general_properties/stop_mpd_on_exit", "0").toInt();
    Controller *control = new Controller(view, nullptr);
    view->rootContext()->setContextProperty("ctl", control);
    view->show();
    int retVal = app->exec();
    if (stopMPDOnExit == 1) { stopMPD(); }
    return retVal;
}
