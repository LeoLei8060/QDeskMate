#include "deskmate.h"
#include <QDebug>
#include <QDir>
#include <QSettings>

DeskMate::DeskMate(QObject *parent)
    : QObject(parent)
    , m_isFolderMode(false)
    , m_intervalTime(1000)
    , m_currentImageIndex(0)
{
    // 读取配置文件
    QSettings settings("settings.ini", QSettings::IniFormat);
    m_isFolderMode = settings.value("isFolderMode", false).toBool();
    auto path = settings.value("imagePath", "qrc:/res/1.gif").toString();
    m_intervalTime = settings.value("intervalTime", 1000).toInt();
    setImagePath(path);

    qDebug() << m_isFolderMode << m_currentImagePath;

    connect(&m_timer, &QTimer::timeout, this, &DeskMate::nextImage);
}

QString DeskMate::imagePath() const
{
    return m_imagePath;
}

void DeskMate::setImagePath(const QString &path)
{
    if (m_imagePath != path) {
        qDebug() << "Original path:" << path;
        m_imagePath = path;
        m_currentImagePath = m_imagePath;
        saveSettings();
        if (m_isFolderMode) {
            loadImagesFromFolder();
        } else {
            // 移除可能的 file:/// 前缀
            if (m_currentImagePath.startsWith("file:///")) {
                m_currentImagePath = m_currentImagePath.mid(8);
            }
            // 仅当路径不是文件系统路径时，添加 qrc:/ 前缀
            if (!m_currentImagePath.startsWith("qrc:/")
                && !QDir::isAbsolutePath(m_currentImagePath)) {
                m_currentImagePath = "qrc:/" + m_currentImagePath;
            }
            qDebug() << "Processed path:" << m_currentImagePath;
            emit currentImagePathChanged();
        }
        emit imagePathChanged();
    }
}

QString DeskMate::currentImagePath() const
{
    return m_currentImagePath;
}

bool DeskMate::isFolderMode() const
{
    return m_isFolderMode;
}

void DeskMate::setIsFolderMode(bool mode)
{
    if (m_isFolderMode != mode) {
        m_isFolderMode = mode;
        if (mode) {
            loadImagesFromFolder();
        } else {
            // 移除可能的 file:/// 前缀
            m_currentImagePath = m_imagePath;
            if (m_currentImagePath.startsWith("file:///")) {
                m_currentImagePath = m_currentImagePath.mid(8);
            }
            emit currentImagePathChanged();
        }
        emit isFolderModeChanged();
        saveSettings();
    }
}

int DeskMate::intervalTime() const
{
    return m_intervalTime;
}

void DeskMate::setIntervalTime(int time)
{
    if (m_intervalTime != time) {
        m_intervalTime = time;
        if (m_timer.isActive()) {
            m_timer.setInterval(time);
        }
        emit intervalTimeChanged();
        saveSettings();
    }
}

void DeskMate::saveSettings()
{
    QSettings settings("settings.ini", QSettings::IniFormat);
    settings.setValue("isFolderMode", m_isFolderMode);
    settings.setValue("imagePath", m_imagePath);
    settings.setValue("intervalTime", m_intervalTime);
}

void DeskMate::loadImagesFromFolder()
{
    m_imageFiles.clear();
    m_currentImageIndex = 0;
    m_timer.stop();

    // 移除可能的 file:/// 前缀
    QString folderPath = m_imagePath;
    if (folderPath.startsWith("file:///")) {
        folderPath = folderPath.mid(8);
    }

    QDir dir(folderPath);
    if (!dir.exists()) {
        m_currentImagePath = "";
        emit currentImagePathChanged();
        return;
    }

    QStringList filters;
    filters << "*.jpg"
            << "*.jpeg"
            << "*.png"
            << "*.gif"
            << "*.bmp";
    m_imageFiles = dir.entryList(filters, QDir::Files);

    // 如果找到图片，设置第一张
    if (!m_imageFiles.isEmpty()) {
        emit currentImagePathChanged();
        m_timer.setInterval(m_intervalTime);
        m_timer.start();
    } else {
        emit currentImagePathChanged();
    }
}

void DeskMate::nextImage()
{
    if (!m_isFolderMode || m_imageFiles.isEmpty())
        return;

    m_currentImageIndex = (m_currentImageIndex + 1) % m_imageFiles.size();

    // 移除可能的 file:/// 前缀
    QString folderPath = m_imagePath;
    if (folderPath.startsWith("file:///")) {
        folderPath = folderPath.mid(8);
    }

    m_currentImagePath = QDir(folderPath).filePath(m_imageFiles[m_currentImageIndex]);
    emit currentImagePathChanged();
}

void DeskMate::updateImage()
{
    if (m_isFolderMode) {
        loadImagesFromFolder();
    } else {
        // 移除可能的 file:/// 前缀
        m_currentImagePath = m_imagePath;
        if (m_currentImagePath.startsWith("file:///")) {
            m_currentImagePath = m_currentImagePath.mid(8);
        }
        emit currentImagePathChanged();
        qDebug() << m_currentImagePath;
    }
}
