#include <QtQuick>
#include <sailfishapp.h>
#include <QtQml>
#include <QObject>
#include "notesmodel.h"
#include "sslconfiguration.h"

int main(int argc, char *argv[])
{
    QGuiApplication* app = SailfishApp::application(argc, argv);
    app->setApplicationDisplayName("Nextcloud Notes");
    app->setApplicationName("harbour-nextcloudnotes");
    app->setApplicationVersion(APP_VERSION);
    app->setOrganizationDomain("https://github.com/scharel");
    app->setOrganizationName("harbour-nextcloudnotes");

    qDebug() << app->applicationDisplayName() << app->applicationVersion();
    qmlRegisterType<NotesModel>("harbour.nextcloudnotes.notesmodel", 1, 0, "NotesModel");
    qmlRegisterType<SslConfiguration>("harbour.nextcloudnotes.sslconfiguration", 1, 0, "SslConfiguration");

    QQuickView* view = SailfishApp::createView();

    view->setSource(SailfishApp::pathTo("qml/harbour-nextcloudnotes.qml"));
#ifdef QT_DEBUG
    view->rootContext()->setContextProperty("debug", QVariant(true));
#else
    view->rootContext()->setContextProperty("debug", QVariant(false));
#endif
    view->show();

    return app->exec();
}
