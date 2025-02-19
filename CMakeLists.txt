cmake_minimum_required(VERSION 3.14)

project(QDeskMate VERSION 1.0 LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt5 COMPONENTS Core Quick QuickControls2 Widgets REQUIRED)

set(PROJECT_SOURCES
        src/main.cpp
        src/qml.qrc
        src/deskmate.h
        src/deskmate.cpp
        src/res/QDeskMate.rc
)

add_executable(QDeskMate
    ${PROJECT_SOURCES}
)

target_compile_definitions(QDeskMate
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(QDeskMate
    PRIVATE Qt5::Core Qt5::Quick Qt5::QuickControls2 Qt5::Widgets)
