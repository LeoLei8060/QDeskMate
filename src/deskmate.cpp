#include "deskmate.h"
#include <QDebug>
#include <QDir>

DeskMate::DeskMate(QObject *parent)
    : QObject(parent)
    , m_isFolderMode(false)
    , m_intervalTime(1000)
    , m_currentIndex(0)
{
    // 设置默认图片路径
    QString defaultImagePath = "qrc:/res/1.gif";
    setImagePath(defaultImagePath);

    connect(&m_timer, &QTimer::timeout, this, &DeskMate::updateImage);
}

QString DeskMate::imagePath() const
{
    return m_imagePath;
}

void DeskMate::setImagePath(const QString &path)
{
    if (m_imagePath != path) {
        m_imagePath = path;
        loadImages();
        emit imagePathChanged();
    }
}

bool DeskMate::isFolderMode() const
{
    return m_isFolderMode;
}

void DeskMate::setIsFolderMode(bool mode)
{
    if (m_isFolderMode != mode) {
        m_isFolderMode = mode;
        loadImages();
        emit isFolderModeChanged();
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
        if (m_isFolderMode && !m_imageFiles.isEmpty()) {
            m_timer.setInterval(m_intervalTime);
        }
        emit intervalTimeChanged();
    }
}

QString DeskMate::currentImage() const
{
    return m_currentImage;
}

void DeskMate::updateImage()
{
    if (m_imageFiles.isEmpty())
        return;

    m_currentIndex = (m_currentIndex + 1) % m_imageFiles.size();
    m_currentImage = m_imageFiles.at(m_currentIndex);
    emit currentImageChanged();
}

void DeskMate::loadImages()
{
    m_timer.stop();
    m_imageFiles.clear();
    m_currentIndex = 0;

    if (m_imagePath.isEmpty())
        return;

    if (m_isFolderMode) {
        QDir        dir(m_imagePath);
        QStringList filters;
        filters << "*.jpg"
                << "*.jpeg"
                << "*.png"
                << "*.gif"
                << "*.bmp";
        m_imageFiles = dir.entryList(filters, QDir::Files);

        // Convert to full paths
        for (int i = 0; i < m_imageFiles.size(); ++i) {
            m_imageFiles[i] = dir.filePath(m_imageFiles[i]);
        }

        if (!m_imageFiles.isEmpty()) {
            m_currentImage = m_imageFiles.first();
            emit currentImageChanged();
            m_timer.setInterval(m_intervalTime);
            m_timer.start();
        }
    } else {
        m_currentImage = m_imagePath;
        emit currentImageChanged();
    }
}
