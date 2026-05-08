qml_module(creomnia-internal
    URI Creomnia.Internal
    SOURCES
        arcgauge.cpp
        circularbuffer.cpp
        circularindicatormanager.cpp
        hyprdevices.cpp
        hyprextras.cpp
        logindmanager.cpp
        sparklineitem.cpp
        visualiserbars.cpp
    LIBRARIES
        Qt::Gui
        Qt::Quick
        Qt::Network
        Qt::DBus
)
