#pragma once

#include "configobject.hpp"

namespace Creomnia::config {

class OverviewConfig : public ConfigObject {
    Q_OBJECT
    QML_ANONYMOUS

    CONFIG_PROPERTY(bool, enabled, true)
    CONFIG_PROPERTY(int, rows, 2)
    CONFIG_PROPERTY(int, columns, 5)
    CONFIG_PROPERTY(qreal, scale, 0.18)
    CONFIG_PROPERTY(bool, orderBottomUp, false)
    CONFIG_PROPERTY(bool, orderRightLeft, false)
    CONFIG_PROPERTY(bool, centerIcons, false)
    CONFIG_PROPERTY(int, arbitraryRaceConditionDelay, 100)

public:
    explicit OverviewConfig(QObject* parent = nullptr)
        : ConfigObject(parent) {}
};

} // namespace Creomnia::config
