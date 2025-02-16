#ifndef DESKMATE_H
#define DESKMATE_H

#include <QObject>
#include <QString>
#include <QTimer>
#include <QDir>
#include <QStringList>

class DeskMate : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString imagePath READ imagePath WRITE setImagePath NOTIFY imagePathChanged)
    Q_PROPERTY(bool isFolderMode READ isFolderMode WRITE setIsFolderMode NOTIFY isFolderModeChanged)
    Q_PROPERTY(int intervalTime READ intervalTime WRITE setIntervalTime NOTIFY intervalTimeChanged)
    Q_PROPERTY(QString currentImage READ currentImage NOTIFY currentImageChanged)

public:
    explicit DeskMate(QObject *parent = nullptr);

    QString imagePath() const;
    void setImagePath(const QString &path);

    bool isFolderMode() const;
    void setIsFolderMode(bool mode);

    int intervalTime() const;
    void setIntervalTime(int time);

    QString currentImage() const;

public slots:
    void updateImage();

signals:
    void imagePathChanged();
    void isFolderModeChanged();
    void intervalTimeChanged();
    void currentImageChanged();

private:
    void loadImages();

    QString m_imagePath;
    bool m_isFolderMode;
    int m_intervalTime;
    QString m_currentImage;
    QStringList m_imageFiles;
    int m_currentIndex;
    QTimer m_timer;
};

#endif // DESKMATE_H
