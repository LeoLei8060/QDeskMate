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
    m_gifImagePath = settings.value("gifImagePath", "qrc:/res/1.gif").toString();
    m_folderImagePath = settings.value("folderImagePath", "").toString();
    m_isFolderMode = settings.value("isFolderMode", false).toBool();
    m_intervalTime = settings.value("intervalTime", 1000).toInt();
    setImagePath(m_isFolderMode ? m_folderImagePath : m_gifImagePath);

    qDebug() << m_isFolderMode << m_currentImagePath;

    connect(&m_timer, &QTimer::timeout, this, &DeskMate::nextImage);
}

QString DeskMate::imagePath() const
{
    return m_isFolderMode ? m_folderImagePath : m_gifImagePath;
}

void DeskMate::setImagePath(const QString &path)
{
    if (m_isFolderMode) {
        m_folderImagePath = path;
    } else {
        m_gifImagePath = path;
    }

    if (m_currentImagePath != path) {
        qDebug() << "Original path:" << path;
        m_currentImagePath = path;
        saveSettings();
        if (m_isFolderMode) {
            loadImagesFromFolder();
        } else {
            m_timer.stop();
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

QString DeskMate::gifImagePath() const
{
    return m_gifImagePath;
}

void DeskMate::setGifImagePath(const QString &path)
{
    m_gifImagePath = path;
}

QString DeskMate::folderImagePath() const
{
    return m_folderImagePath;
}

void DeskMate::setFolderImagePath(const QString &path)
{
    m_folderImagePath = path;
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
            setImagePath(m_folderImagePath);
            loadImagesFromFolder();
        } else {
            setImagePath(m_gifImagePath);
            // 移除可能的 file:/// 前缀
            m_currentImagePath = m_gifImagePath;
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
    settings.setValue("gifImagePath", m_gifImagePath);
    settings.setValue("folderImagePath", m_folderImagePath);
    settings.setValue("intervalTime", m_intervalTime);
}

void DeskMate::loadImagesFromFolder()
{
    QDir dir(m_folderImagePath);
    if (!dir.exists()) {
        qDebug() << "Folder does not exist:" << m_folderImagePath;
        return;
    }

    QStringList nameFilters;
    nameFilters << "*.jpg"
                << "*.jpeg"
                << "*.png"
                << "*.gif"
                << "*.bmp";
    m_imageFiles = dir.entryList(nameFilters, QDir::Files);

    if (m_imageFiles.isEmpty()) {
        qDebug() << "No images found in folder:" << m_folderImagePath;
        return;
    }

    m_currentImageIndex = 0;
    m_currentImagePath = dir.filePath(m_imageFiles[m_currentImageIndex]);
    emit currentImagePathChanged();
    m_timer.setInterval(m_intervalTime);
    m_timer.start();
}

void DeskMate::nextImage()
{
    if (m_imageFiles.isEmpty()) {
        return;
    }

    m_currentImageIndex = (m_currentImageIndex + 1) % m_imageFiles.size();
    QDir dir(m_folderImagePath);
    m_currentImagePath = dir.filePath(m_imageFiles[m_currentImageIndex]);
    emit currentImagePathChanged();
}

void DeskMate::updateImage()
{
    if (m_isFolderMode) {
        loadImagesFromFolder();
    } else {
        m_currentImagePath = m_gifImagePath;
        if (m_currentImagePath.startsWith("file:///")) {
            m_currentImagePath = m_currentImagePath.mid(8);
        }
        if (!m_currentImagePath.startsWith("qrc:/") && !QDir::isAbsolutePath(m_currentImagePath)) {
            m_currentImagePath = "qrc:/" + m_currentImagePath;
        }
        emit currentImagePathChanged();
    }
}
