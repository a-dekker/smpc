#include <QGuiApplication>
#include <QQuickView>
#include <QDebug>
#include <QProcess>

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

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QProcess appinfo;
    QString appversion;
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setOrganizationName("harbour-smpc");
    app->setApplicationName("harbour-smpc");
    appinfo.start("/bin/rpm", QStringList() << "-qa"
                                            << "--queryformat"
                                            << "%{version}-%{RELEASE}"
                                            << "harbour-smpc");
    appinfo.waitForFinished(-1);
    if (appinfo.bytesAvailable() > 0) {
        appversion = appinfo.readAll();
    }

    ResourceHandler *resourceHandler = new ResourceHandler();

    QLocale::setDefault(QLocale::c());
    QQuickView *view = SailfishApp::createView();
    view->engine()->addImportPath("/usr/share/harbour-smpc/qml/");
    view->setSource(SailfishApp::pathTo("qml/main.qml"));
    view->setDefaultAlphaBuffer(true);
    view->rootContext()->setContextProperty("version", appversion);
    view->rootContext()->setContextProperty(QLatin1String("resourceHandler"), resourceHandler);

    foreach(QString path, view->engine()->importPathList()) {
        qDebug() << path;
    }

    QSettings mySets;
    int stopMPDOnExit = mySets.value("general_properties/stop_mpd_on_exit", "0").toInt();
    Controller *control = new Controller(view, nullptr);
    view->rootContext()->setContextProperty("ctl", control);
    view->show();
    int retVal = app->exec();
    if (stopMPDOnExit == 1) { stopMPD(); }
    return retVal;
}
