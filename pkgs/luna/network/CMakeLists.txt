cmake_minimum_required(VERSION 4.0)
project(network LANGUAGES CXX C)

set(CMAKE_EXPORT_COMPILE_COMMANDS on)
set(QT_QML_GENERATE_QMLLS_INI on)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick Qml Gui)
qt_standard_project_setup(REQUIRES 6.10)
qt_add_qml_module(network
  URI Luna.Network
  VERSION 1.0
  OUTPUT_DIRECTORY Luna/Network
  SOURCES
  network.h
  network.cpp
)
find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBNM REQUIRED libnm)
target_link_libraries(network PRIVATE
    ${GLIB_LIBRARIES}
    ${LIBNM_LIBRARIES}
)
target_include_directories(network PRIVATE
    ${GLIB_INCLUDE_DIRS}
    ${LIBNM_INCLUDE_DIRS}
)
target_compile_options(network PRIVATE
    ${GLIB_CFLAGS_OTHER}
     ${LIBNM_CFLAGS_OTHER}
)
add_compile_definitions(QT_NO_KEYWORDS)
#install(TARGETS moon DESTINATION lib/qt-6/qml/Luna/Moon)
#install(TARGETS moonplugin DESTINATION lib/qt-6/qml/Luna/Moon)
#install(FILES
#  ${CMAKE_CURRENT_BINARY_DIR}/Luna/Moon/qmldir
#  ${CMAKE_CURRENT_BINARY_DIR}/Luna/Moon/moon.qmltypes
#  ${CMAKE_CURRENT_BINARY_DIR}/Luna/Moon/moon_qml_module_dir_map.qrc
#  DESTINATION lib/qt-6/qml/Luna/Moon
#)
