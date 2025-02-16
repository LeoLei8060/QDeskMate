#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QSystemTrayIcon>
#include <QMenu>
#include <QAction>
#include <QApplication>
#include "deskmate.h"

int main(int argc, char *argv[])
{
    QGuiApplication::setOrganizationName("QDeskMate");
    QGuiApplication::setOrganizationDomain("qdeskmate.com");
    QGuiApplication::setApplicationName("QDeskMate");
    
    QApplication app(argc, argv);
    QQuickStyle::setStyle("Basic");
    
    QQmlApplicationEngine engine;
    
    DeskMate deskMate;
    engine.rootContext()->setContextProperty("deskMate", &deskMate);
    
    // 创建系统托盘
    QSystemTrayIcon *trayIcon = new QSystemTrayIcon();
    trayIcon->setIcon(QIcon(":/res/1.gif")); // 使用应用图标
    
    // 创建托盘菜单
    QMenu *trayMenu = new QMenu();
    QAction *settingsAction = new QAction("设置", trayMenu);
    QAction *quitAction = new QAction("退出", trayMenu);
    
    trayMenu->addAction(settingsAction);
    trayMenu->addSeparator();
    trayMenu->addAction(quitAction);
    
    trayIcon->setContextMenu(trayMenu);
    trayIcon->show();
    
    // 连接信号
    QObject::connect(settingsAction, &QAction::triggered, [&engine]() {
        QMetaObject::invokeMethod(engine.rootObjects().first(), "showSettings");
    });
    
    QObject::connect(quitAction, &QAction::triggered, &app, &QApplication::quit);
    
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    engine.load(url);
    
    return app.exec();
}
