cmake_minimum_required(VERSION 3.16)
project(notification_listener LANGUAGES CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick DBus Qml)

# Add modules to QML
qt_add_qml_module(notification_listener
    VERSION 1.0
    URI NotificationListener
    PLUGIN_TARGET notification_listener
    TYPEINFO NotificationListener.qmltypes
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/NotificationListener
    SOURCES
        native/NotificationListener.cpp
        native/NotificationListener.hpp
        native/NotificationListenerAdaptor.cpp
        native/NotificationListenerAdaptor.hpp
)

target_include_directories(notification_listener PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/native)

target_link_libraries(notification_listener PRIVATE Qt6::Core Qt6::Quick Qt6::DBus Qt6::Qml)

set_target_properties(notification_listener PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/NotificationListener
)

install(TARGETS notification_listener
    LIBRARY DESTINATION lib/qt6/qml/NotificationListener
)

if(EXISTS "${CMAKE_CURRENT_BINARY_DIR}/lib/NotificationListener/NotificationListener.qmltypes")
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/lib/NotificationListener/NotificationListener.qmltypes
        DESTINATION lib/qt6/qml/NotificationListener
    )
endif()

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/lib/NotificationListener/qmldir
    DESTINATION lib/qt6/qml/NotificationListener
)
