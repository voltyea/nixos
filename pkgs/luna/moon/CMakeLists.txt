cmake_minimum_required(VERSION 4.0)
project(moon LANGUAGES CXX C)

  set(CMAKE_EXPORT_COMPILE_COMMANDS on)
  set(QT_QML_GENERATE_QMLLS_INI on)
  set(CMAKE_AUTOMOC ON)
  set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

  find_package(Qt6 REQUIRED COMPONENTS Core Quick Qml)
qt_standard_project_setup(REQUIRES 6.10)
  qt_add_qml_module(moon
      URI Luna.Moon
      VERSION 1.0
      OUTPUT_DIRECTORY Luna/Moon
      SOURCES
      moon.h
      moon.cpp
      lib/astronomy.c
      )

target_link_libraries(moon PRIVATE Qt::Core Qt::Qml Qt::Quick)

  install(TARGETS moon DESTINATION lib/qt-6/qml/Luna/Moon)
install(TARGETS moonplugin DESTINATION lib/qt-6/qml/Luna/Moon)
  install(FILES
      ${CMAKE_CURRENT_BINARY_DIR}/Luna/Moon/qmldir
      ${CMAKE_CURRENT_BINARY_DIR}/Luna/Moon/moon.qmltypes
      ${CMAKE_CURRENT_BINARY_DIR}/Luna/Moon/moon_qml_module_dir_map.qrc
      DESTINATION lib/qt-6/qml/Luna/Moon
      )
