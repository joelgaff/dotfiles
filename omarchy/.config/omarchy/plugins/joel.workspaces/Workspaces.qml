import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

// Per-monitor workspace indicators.
//
// Clone of omarchy.workspaces. Stock builds one global list and draws it in
// every bar, so with workspaces split across two monitors each bar reported the
// other's as well. Omarchy 3.x did not have this problem: Waybar's
// hyprland/workspaces module filtered by output on its own, and the shell's
// move to Quickshell in 4.0 carried over the pinned 1-5 (as the hardcoded
// floor below) but not the filtering. This adds the filtering back.
BarWidget {
  id: root
  moduleName: "joel.workspaces"

  // The output this bar surface is drawn on. One surface exists per monitor,
  // so this is what makes the widget per-monitor rather than global.
  readonly property var barWindow: root.QsWindow ? root.QsWindow.window : null
  readonly property string screenName: barWindow && barWindow.screen ? String(barWindow.screen.name || "") : ""

  readonly property bool internalScreen: /^(eDP|LVDS|DSI)-/.test(root.screenName)
  readonly property bool docked: Hyprland.monitors.values.length > 1

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  // Numbers this bar always shows, mirroring the workspace rules in
  // ~/.config/hypr/hosts/<hostname>.lua: docked, 1-5 are the external's and
  // 6-10 the laptop panel's. Undocked, everything collapses onto the one
  // screen, so it shows 1-5 exactly as a single-monitor machine always did.
  function floorIds() {
    if (root.docked && root.internalScreen) return [6, 7, 8, 9, 10]

    return [1, 2, 3, 4, 5]
  }

  function workspaceIds() {
    var ids = root.floorIds()
    var values = Hyprland.workspaces.values

    for (var i = 0; i < values.length; i++) {
      var workspace = values[i]
      // The filter stock is missing. A workspace living on another monitor is
      // that monitor's bar's business, not ours.
      if (!workspace.monitor || String(workspace.monitor.name || "") !== root.screenName) continue

      var id = workspace.id
      if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  // One property so the Repeater and the column count always agree. QML tracks
  // everything workspaceIds() touches -- this bar's screen, the monitor list,
  // and each workspace's monitor -- so moving a workspace between displays
  // re-evaluates it.
  readonly property var ids: root.workspaceIds()

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.ids.length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.ids

      WidgetButton {
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData

        bar: root.bar
        text: focused ? "\uDB85\uDCFB" : (modelData === 10 ? "0" : String(modelData))
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }
}
