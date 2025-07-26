cmake_minimum_required(VERSION 4.0)
project(CppModulePlugin LANGUAGES CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Qml)

qt_add_qml_module(CppModulePlugin
    VERSION 1.0
    URI HyprShell.CppModulePlugin
    PLUGIN_TARGET CppModulePlugin
    TYPEINFO CppModulePlugin.qmltypes
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
    SOURCES
        native/CppBackend.cpp
        native/CppBackend.hpp
)

target_include_directories(CppModulePlugin PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/native)
target_link_libraries(CppModulePlugin PRIVATE Qt6::Core Qt6::Qml)

set_target_properties(CppModulePlugin PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)

install(TARGETS CppModulePlugin
    LIBRARY DESTINATION lib/qt6/qml/HyprShell/CppModulePlugin
)

if(EXISTS "${CMAKE_CURRENT_BINARY_DIR}/CppModulePlugin.qmltypes")
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/lib/CppModulePlugin.qmltypes
        DESTINATION lib/qt6/qml/HyprShell/CppModulePlugin
    )
endif()

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/lib/qmldir
    DESTINATION lib/qt6/qml/HyprShell/CppModulePlugin
)
