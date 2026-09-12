import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

// The Gesture Cheatsheet popup: lists the Windows-style touchpad gestures
// configured by omarchy-gestures, and links out to the source repo so the
// panel is a jumping-off point rather than a copy.
Panel {
  id: root
  moduleName: "io.github.mittai17.gesture-cheatsheet"
  ipcTarget: root.moduleName
  manageIpc: false

  property var anchorItem: null

  // The bar tracks the widget mounted in its slot — BarWidget.qml — not this
  // nested panel, so the popout coordinator has to compare against the host
  // widget. Mirrors the built-in clock's panel contract.
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root

  // Guarded so the panel renders before the bar is injected.
  readonly property color contentForeground: bar ? bar.foreground : Color.foreground
  readonly property string contentFontFamily: bar ? bar.fontFamily : Style.font.family

  readonly property string repoUrl: "https://github.com/mittai17/omarchy-gestures"
  readonly property string installCommand: "git clone " + root.repoUrl + " && cd omarchy-gestures && ./install.sh"
  property bool copied: false

  // The gestures the omarchy-gestures config actually wires up.
  readonly property var gestures: [
    { gesture: "4-finger  ←  →", action: "Switch workspace" },
    { gesture: "4-finger  ↓  ↑", action: "Minimize all / restore" },
    { gesture: "3-finger  ←  →", action: "Cycle windows (Alt-Tab)" },
    { gesture: "3-finger  ↑", action: "App menu" }
  ]

  function openRepo() {
    repoProc.command = ["xdg-open", root.repoUrl]
    repoProc.running = true
  }

  function copyInstall() {
    copyProc.command = ["wl-copy", root.installCommand]
    copyProc.running = true
    root.copied = true
    copiedTimer.restart()
  }

  Process {
    id: repoProc
  }

  Process {
    id: copyProc
  }

  Timer {
    id: copiedTimer
    interval: 1500
    onTriggered: root.copied = false
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(420))
    contentHeight: panel.fittedContentHeight(contentColumn.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onActivateRequested: root.openRepo()
      onCloseRequested: root.close()
    }

    Column {
      id: contentColumn
      width: parent.width
      spacing: Style.space(12)

      PanelSectionHeader {
        width: parent.width
        text: "Touchpad gestures"
        foreground: root.contentForeground
        fontFamily: root.contentFontFamily
      }

      Repeater {
        model: root.gestures

        Item {
          required property var modelData
          width: parent.width

          Row {
            width: parent.width
            spacing: Style.space(14)

            Text {
              width: (parent.width - parent.spacing) / 2
              text: modelData.gesture
              color: root.contentForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.body
              font.bold: true
              elide: Text.ElideRight
            }

            Text {
              width: (parent.width - parent.spacing) / 2
              text: modelData.action
              color: Qt.darker(root.contentForeground, 1.35)
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.body
              wrapMode: Text.WordWrap
            }
          }
        }
      }

      PanelSeparator {
        width: parent.width
        foreground: root.contentForeground
      }

      PanelSectionHeader {
        width: parent.width
        text: "Powered by omarchy-gestures"
        foreground: root.contentForeground
        fontFamily: root.contentFontFamily
      }

      Text {
        width: parent.width
        text: "Windows-style gestures configured in Hyprland (~/.config/hypr/gestures.lua)."
        color: Qt.darker(root.contentForeground, 1.35)
        font.family: root.contentFontFamily
        font.pixelSize: Style.font.bodySmall
        wrapMode: Text.WordWrap
      }

      Rectangle {
        width: parent.width
        height: cmdText.implicitHeight + Style.space(12)
        radius: Style.cornerRadius
        color: Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.08)

        Text {
          id: cmdText
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: Style.space(10)
          anchors.rightMargin: Style.space(10)
          anchors.verticalCenter: parent.verticalCenter
          text: root.installCommand
          color: root.contentForeground
          font.family: root.contentFontFamily
          font.pixelSize: Style.font.caption
          wrapMode: Text.WordWrap
        }
      }

      Row {
        width: parent.width
        spacing: Style.space(8)

        Rectangle {
          implicitWidth: openText.implicitWidth + Style.space(24)
          implicitHeight: Style.spacing.controlHeight
          radius: Style.cornerRadius
          color: openArea.containsMouse
            ? Style.hoverFillFor(root.contentForeground, Color.accent)
            : "transparent"
          border.width: Style.spacing.hairline
          border.color: Style.normalBorderFor(root.contentForeground, Color.accent)

          Text {
            id: openText
            anchors.centerIn: parent
            text: "Open repo"
            color: root.contentForeground
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.bodySmall
          }

          MouseArea {
            id: openArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openRepo()
          }
        }

        Rectangle {
          implicitWidth: copyText.implicitWidth + Style.space(24)
          implicitHeight: Style.spacing.controlHeight
          radius: Style.cornerRadius
          color: copyArea.containsMouse
            ? Style.hoverFillFor(root.contentForeground, Color.accent)
            : "transparent"
          border.width: Style.spacing.hairline
          border.color: Style.normalBorderFor(root.contentForeground, Color.accent)

          Text {
            id: copyText
            anchors.centerIn: parent
            text: root.copied ? "Copied" : "Copy install command"
            color: root.copied ? Color.accent : root.contentForeground
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.bodySmall
            font.bold: root.copied
          }

          MouseArea {
            id: copyArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.copyInstall()
          }
        }
      }
    }
  }
}