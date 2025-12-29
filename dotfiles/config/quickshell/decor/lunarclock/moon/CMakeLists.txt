cmake_minimum_required(VERSION 4.0)
project(moon)

set(CMAKE_EXPORT_COMPILE_COMMANDS on)
set(QT_QML_GENERATE_QMLLS_INI on)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick Qml Gui)
qt_standard_project_setup(REQUIRES 6.10)
qt_add_qml_module(moon
  URI Moon
  VERSION 1.0
  OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/Moon"
  SOURCES
  moon.h
  moon.cpp
  lib/astronomy.c
)
