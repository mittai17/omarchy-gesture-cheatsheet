import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.mittai17.gesture-cheatsheet"

  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false
  function open() { if (panelLoader.item) panelLoader.item.open() }
  function close() { if (panelLoader.item) panelLoader.item.close() }
  function togglePanel() { if (panelLoader.item) panelLoader.item.toggle() }
  readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false
  function closeForPopoutSwitch() { if (panelLoader.item) panelLoader.item.closeForPopoutSwitch() }

  function injectPanel() {
    var t = panelLoader.item
    if (!t) return
    if ("bar" in t) t.bar = root.bar
    if ("settings" in t) t.settings = root.settings
    if ("anchorItem" in t) t.anchorItem = iconRow
    if ("hostWidget" in t) t.hostWidget = root
  }

  readonly property color foreground: bar ? bar.barForeground : Color.foreground
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  property real iconSize: Math.max(14, barSize - 8)

  implicitWidth: iconRow.implicitWidth
  implicitHeight: bar ? bar.barSize : Style.bar.sizeHorizontal

  onBarChanged: { injectPanel(); syncClickRegistration() }
  onSettingsChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: { root.injectPanel(); Qt.callLater(root.injectPanel) }
  }

  IpcHandler {
    target: root.moduleName
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.togglePanel() }
  }

  // ---- Icon + label row ---------------------------------------------------
  Row {
    id: iconRow
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.space(4)

    Rectangle {
      width: root.iconSize
      height: root.iconSize
      radius: Style.cornerRadius
      clip: true
      border.width: Style.spacing.hairline
      border.color: Style.normalBorderFor(root.foreground, Color.accent)

      Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("preview.png")
        fillMode: Image.PreserveAspectCrop
        smooth: true
      }
    }

    Text {
      text: root.setting("barLabel", "Gestures")
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  // ---- Hover / click (mirrors WidgetButton's bar registration) --------------
  property var registeredBar: null
  function syncClickRegistration() {
    if (registeredBar && registeredBar.unregisterClickTarget) registeredBar.unregisterClickTarget(root)
    registeredBar = root.bar
    if (registeredBar && registeredBar.registerClickTarget) registeredBar.registerClickTarget(root)
  }

  Component.onCompleted: syncClickRegistration()
  Component.onDestruction: { if (registeredBar && registeredBar.unregisterClickTarget) registeredBar.unregisterClickTarget(root) }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    cursorShape: Qt.PointingHandCursor
    onEntered: { if (root.bar) root.bar.showTooltip(root, "Touchpad gesture cheat sheet") }
    onExited:  { if (root.bar) root.bar.hideTooltip(root) }
    onClicked: function(mouse) { root.togglePanel() }
    onWheel:   function(wheel) { /* no-op */ }
  }
}
