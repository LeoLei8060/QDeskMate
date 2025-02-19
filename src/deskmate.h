#ifndef DESKMATE_H
#define DESKMATE_H

#include <QDir>
#include <QObject>
#include <QString>
#include <QStringList>
#include <QTimer>
#include <QVariantList>
#include <QVariantMap>

class DeskMate : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString imagePath READ imagePath WRITE setImagePath NOTIFY imagePathChanged)
    Q_PROPERTY(QString gifImagePath READ gifImagePath WRITE setGifImagePath)
    Q_PROPERTY(QString folderImagePath READ folderImagePath WRITE setFolderImagePath)
    Q_PROPERTY(QString currentImagePath READ currentImagePath NOTIFY currentImagePathChanged)
    Q_PROPERTY(bool isFolderMode READ isFolderMode WRITE setIsFolderMode NOTIFY isFolderModeChanged)
    Q_PROPERTY(int intervalTime READ intervalTime WRITE setIntervalTime NOTIFY intervalTimeChanged)
    Q_PROPERTY(QVariantList tasks READ tasks NOTIFY tasksChanged)
    Q_PROPERTY(int taskCount READ taskCount CONSTANT)

public:
    explicit DeskMate(QObject *parent = nullptr);

    QString          imagePath() const;
    Q_INVOKABLE void setImagePath(const QString &path);

    QString          gifImagePath() const;
    Q_INVOKABLE void setGifImagePath(const QString &path);

    QString          folderImagePath() const;
    Q_INVOKABLE void setFolderImagePath(const QString &path);

    QString currentImagePath() const;

    bool isFolderMode() const;
    void setIsFolderMode(bool mode);

    int  intervalTime() const;
    void setIntervalTime(int time);

    QVariantList tasks() const;
    int taskCount() const { return m_tasks.size(); }
    Q_INVOKABLE QVariantMap getTask(int index) const;
    Q_INVOKABLE void updateTaskText(int index, const QString &text);
    Q_INVOKABLE void updateTaskStatus(int index, bool completed);
    Q_INVOKABLE void updateTask(int index, const QString &text, bool completed);

    void saveSettings();

public slots:
    void updateImage();
    void nextImage();

signals:
    void imagePathChanged();
    void currentImagePathChanged();
    void isFolderModeChanged();
    void intervalTimeChanged();
    void tasksChanged();

private:
    void loadImagesFromFolder();
    void loadTasks();
    void saveTasks();

    QString     m_gifImagePath;
    QString     m_folderImagePath;
    QString     m_currentImagePath;
    bool        m_isFolderMode;
    int         m_intervalTime;
    QStringList m_imageFiles;
    int         m_currentImageIndex;
    QTimer      m_timer;
    QVariantList m_tasks;
};

#endif // DESKMATE_H
