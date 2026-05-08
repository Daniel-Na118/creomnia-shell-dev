#pragma once

#include "configobject.hpp"

#include <qstringlist.h>

namespace Creomnia::config {

class DockConfig : public ConfigObject {
    Q_OBJECT
    QML_ANONYMOUS

    CONFIG_PROPERTY(bool, enabled, true)
    CONFIG_PROPERTY(bool, pinnedOnStartup, false)
    CONFIG_PROPERTY(bool, showPreviews, true)
    CONFIG_PROPERTY(bool, monochromeIcons, false)
    CONFIG_PROPERTY(int, height, 60)
    CONFIG_PROPERTY(int, iconSize, 35)
    CONFIG_PROPERTY(int, floatMargin, 12)
    CONFIG_PROPERTY(int, dragThreshold, 30)
    CONFIG_PROPERTY(qreal, hoverRegionWidthFraction, 0.5)
    CONFIG_PROPERTY(int, hoverRegionHeight, 40)
    CONFIG_PROPERTY(int, maxWindowPreviewWidth, 300)
    CONFIG_PROPERTY(int, maxWindowPreviewHeight, 200)
    CONFIG_GLOBAL_PROPERTY(QStringList, pinnedApps)
    CONFIG_GLOBAL_PROPERTY(QStringList, ignoredAppRegexes)
    CONFIG_GLOBAL_PROPERTY(QStringList, excludedScreens)

public:
    explicit DockConfig(QObject* parent = nullptr)
        : ConfigObject(parent) {}
};

} // namespace Creomnia::config
