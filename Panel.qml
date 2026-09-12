import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

// The Gesture Cheatsheet popup: lists the Windows-style touchpad gestures
// configured by omarchy-gestures, and links out to the source repo.
//
// Content is user-tunable. "Customize" swaps the static rows for Toggle rows
// that show/hide each gesture, the install section, and the bar label; all of
// it is persisted to this widget's inline shell.json entry, so what you see is
// what the shell restores on restart.
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

  // Customization mode: flips the static list into per-row toggles. Transient
  // (not persisted) — it is an editing mode, not a preference.
  property bool editMode: false

  // The gestures the omarchy-gestures config actually wires up. Each one maps
  // to a persisted show/hide setting keyed by `key`.
  readonly property var gestures: [
    { key: "showWorkspaceSwitch", gesture: "4-finger  ←  →", action: "Switch workspace" },
    { key: "showMinimizeAll", gesture: "4-finger  ↓  ↑", action: "Minimize all / restore" },
    { key: "showCycleWindows", gesture: "3-finger  ←  →", action: "Cycle windows (Alt-Tab)" },
    { key: "showAppMenu", gesture: "3-finger  ↑", action: "App menu" }
  ]

  readonly property bool showInstallSection: root.boolSetting("showInstallSection", true)
  readonly property string barLabel: String(root.setting("barLabel", "Gestures"))

  function boolSetting(name, fallback) {
    var v = root.setting(name, fallback)
    if (v === true || v === 1) return true
    if (v === false || v === 0) return false
    var s = String(v).replace(/^\s+|\s+$/g, "").toLowerCase()
    return !(s === "false" || s === "0" || s === "no" || s === "off")
  }

  function gestureVisible(g) {
    return root.boolSetting(g.key, true)
  }

  // Mirrors the built-in clock's persistence: apply locally first, then write
  // the whole entry back through the bar so shell.json keeps the same value.
  function persistSettings(values) {
    var entry = { id: root.moduleName }
    for (var existing in root.settings) if (existing !== "id") entry[existing] = root.settings[existing]
    for (var key in values) entry[key] = values[key]

    root.settings = entry
    if (root.hostWidget && "settings" in root.hostWidget) root.hostWidget.settings = entry
    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function")
      root.bar.shell.updateEntryInline(root.moduleName, entry)
  }

  function toggleGesture(g) {
    var values = {}
    values[g.key] = !root.gestureVisible(g)
    root.persistSettings(values)
  }

  function commitBarLabel() {
    if (String(labelField.text) !== String(root.barLabel))
      root.persistSettings({ barLabel: labelField.text })
  }

  function resetSettings() {
    var values = {}
    for (var i = 0; i < root.gestures.length; i++) values[root.gestures[i].key] = true
    values.showInstallSection = true
    values.barLabel = "Gestures"
    root.persistSettings(values)
  }

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
      spacing: Style.space(10)

      // ---- Logo --------------------------------------------------------
      Rectangle {
        width: Math.min(parent.width * 0.55, Style.space(120))
        height: width
        anchors.horizontalCenter: parent.horizontalCenter
        radius: Style.cornerRadius
        border.width: Style.spacing.hairline
        border.color: Style.normalBorderFor(root.contentForeground, Color.accent)
        clip: true

        Image {
          anchors.fill: parent
          source: Qt.resolvedUrl("preview.png")
          fillMode: Image.PreserveAspectCrop
          smooth: true
        }
      }

      // ---- Header: section title + Customize/Done toggle ---------------
      Row {
        width: parent.width
        spacing: Style.space(8)

        PanelSectionHeader {
          width: contentColumn.width - customizePill.width - parent.spacing
          anchors.verticalCenter: parent.verticalCenter
          text: root.editMode ? "Customize cheat sheet" : "Touchpad gestures"
          foreground: root.contentForeground
          fontFamily: root.contentFontFamily
        }

        Rectangle {
          id: customizePill
          implicitWidth: customizeText.implicitWidth + Style.space(24)
          implicitHeight: Style.spacing.controlHeight
          radius: Style.cornerRadius
          color: customizeArea.containsMouse
            ? Style.hoverFillFor(root.contentForeground, Color.accent)
            : "transparent"
          border.width: Style.spacing.hairline
          border.color: Style.normalBorderFor(root.contentForeground, Color.accent)

          Text {
            id: customizeText
            anchors.centerIn: parent
            text: root.editMode ? "Done" : "Customize"
            color: root.editMode ? Color.accent : root.contentForeground
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.bodySmall
            font.bold: root.editMode
          }

          MouseArea {
            id: customizeArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.editMode = !root.editMode
          }
        }
      }

      // ---- Static rows (normal mode) -----------------------------------
      Repeater {
        model: root.gestures
        visible: !root.editMode

        Item {
          required property var modelData
          width: parent.width
          visible: root.gestureVisible(modelData)

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

      // ---- Edit rows (customize mode) ----------------------------------
      Item {
        visible: root.editMode
        width: parent.width

        Column {
          width: parent.width
          spacing: Style.space(8)

          Text {
            width: parent.width
            text: "Show / hide each gesture. Settings are stored in the widget's shell.json entry."
            color: Qt.darker(root.contentForeground, 1.35)
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.caption
            wrapMode: Text.WordWrap
          }

          Repeater {
            model: root.gestures

            Toggle {
              required property var modelData
              width: parent.width
              label: modelData.gesture
              description: modelData.action
              checked: root.gestureVisible(modelData)
              rounded: Style.cornerRadius > 0
              foreground: root.contentForeground
              accent: Color.accent
              fontFamily: root.contentFontFamily

              onClicked: root.toggleGesture(modelData)
            }
          }

          Toggle {
            width: parent.width
            label: "Install section"
            description: "Repo link, install command, and copy button at the bottom"
            checked: root.showInstallSection
            rounded: Style.cornerRadius > 0
            foreground: root.contentForeground
            accent: Color.accent
            fontFamily: root.contentFontFamily

            onClicked: root.persistSettings({ showInstallSection: !root.showInstallSection })
          }

          PanelSeparator {
            width: parent.width
            foreground: root.contentForeground
          }

          Text {
            width: parent.width
            text: "Bar label"
            color: Qt.darker(root.contentForeground, 1.4)
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.caption
            font.bold: true
          }

          TextField {
            id: labelField
            width: parent.width
            text: root.barLabel
            foreground: root.contentForeground
            accent: Color.accent
            onAccepted: root.commitBarLabel()
            onEditingFinished: root.commitBarLabel()
          }

          Row {
            spacing: Style.space(8)

            Rectangle {
              implicitWidth: resetText.implicitWidth + Style.space(24)
              implicitHeight: Style.spacing.controlHeight
              radius: Style.cornerRadius
              color: resetArea.containsMouse
                ? Style.hoverFillFor(root.contentForeground, Color.accent)
                : "transparent"
              border.width: Style.spacing.hairline
              border.color: Style.normalBorderFor(root.contentForeground, Color.accent)

              Text {
                id: resetText
                anchors.centerIn: parent
                text: "Reset to defaults"
                color: root.contentForeground
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.bodySmall
              }

              MouseArea {
                id: resetArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.resetSettings()
              }
            }
          }
        }
      }

      // ---- Install footer (normal mode only) ---------------------------
      Column {
        visible: !root.editMode && root.showInstallSection
        width: parent.width
        spacing: Style.space(10)

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
}