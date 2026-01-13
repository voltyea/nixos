cmake_minimum_required(VERSION 4.0)
project(network LANGUAGES CXX C)

  set(CMAKE_EXPORT_COMPILE_COMMANDS on)
  set(QT_QML_GENERATE_QMLLS_INI on)
  set(CMAKE_AUTOMOC ON)
  set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

  find_package(Qt6 REQUIRED COMPONENTS Core Quick Qml DBus)
qt_standard_project_setup(REQUIRES 6.10)
  qt_add_qml_module(network
      URI Luna.Network
      VERSION 1.0
      OUTPUT_DIRECTORY Luna/Network
      SOURCES
      network.h
      network.cpp
      )

  target_link_libraries(network PRIVATE
      Qt6::Core
      Qt6::Qml
      Qt6::Quick
      Qt6::DBus
      )

  target_include_directories(network PRIVATE
      ${CMAKE_CURRENT_BINARY_DIR}
      )

install(TARGETS network DESTINATION lib/qt-6/qml/Luna/Network)

install(TARGETS networkplugin DESTINATION lib/qt-6/qml/Luna/Network)

  install(FILES
      ${CMAKE_CURRENT_BINARY_DIR}/Luna/Network/qmldir
      ${CMAKE_CURRENT_BINARY_DIR}/Luna/Network/network.qmltypes
      ${CMAKE_CURRENT_BINARY_DIR}/Luna/Network/network_qml_module_dir_map.qrc
      DESTINATION lib/qt-6/qml/Luna/Network
      )
