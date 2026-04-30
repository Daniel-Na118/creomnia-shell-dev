import Quickshell.Io

JsonObject {
    property bool enabled: true
    property bool pinnedOnStartup: false
    property bool showPreviews: true
    property bool monochromeIcons: false
    property int height: 60
    property int iconSize: 35
    property int floatMargin: 12
    property int dragThreshold: 30
    property real hoverRegionWidthFraction: 0.5
    property int hoverRegionHeight: 100
    property int maxWindowPreviewWidth: 300
    property int maxWindowPreviewHeight: 200
    property list<string> pinnedApps: []
    property list<string> ignoredAppRegexes: []
    property list<string> excludedScreens: []
}
