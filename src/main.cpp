#include "deskmate.h"
#include <QAction>
#include <QApplication>
#include <QMenu>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QSystemTrayIcon>

int main(int argc, char *argv[])
{
    QGuiApplication::setOrganizationName("QDeskMate");
    QGuiApplication::setOrganizationDomain("qdeskmate.com");
    QGuiApplication::setApplicationName("QDeskMate");

    QApplication app(argc, argv);
    QQuickStyle::setStyle("Basic");

    qmlRegisterType<DeskMate>("com.deskmate.backend", 1, 0, "DeskMate");

    QQmlApplicationEngine engine;

    DeskMate deskMate;
    engine.rootContext()->setContextProperty("deskMate", &deskMate);

    // 创建系统托盘图标
    QSystemTrayIcon *trayIcon = new QSystemTrayIcon(&app);
    trayIcon->setIcon(QIcon(":/res/1.gif"));
    trayIcon->setToolTip("QDeskMate");

    // 创建托盘菜单
    QMenu *trayMenu = new QMenu();

    QAction *settingsAction = new QAction("设置", trayMenu);
    QObject::connect(settingsAction, &QAction::triggered, [&engine]() {
        QObject *rootObject = engine.rootObjects().first();
        QObject *settingsDialog = rootObject->findChild<QObject *>("settingsDialog");
        if (settingsDialog) {
            QMetaObject::invokeMethod(settingsDialog, "open");
        }
    });

    QAction *quitAction = new QAction("退出", trayMenu);

    trayMenu->addAction(settingsAction);
    trayMenu->addSeparator();
    trayMenu->addAction(quitAction);

    trayIcon->setContextMenu(trayMenu);
    trayIcon->show();

    QObject::connect(quitAction, &QAction::triggered, &app, &QApplication::quit);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
