import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Blanks the displays (DPMS off) after `idle.displayOff` seconds of inactivity
// and lights them back up on the next input. Deliberately does not lock: the
// first-party omarchy.idle service still owns the screensaver and lock stages,
// so this only adds an earlier, password-free blank.
Item {
  id: root

  // Injected by omarchy-shell (the first-party service loader).
  property var shell: null

  readonly property string stayAwakeStateDir: Quickshell.env("HOME") + "/.local/state/omarchy/indicators"
  readonly property int defaultTimeoutSeconds: 600
  readonly property var idleConfig: shell && shell.shellConfig && shell.shellConfig.idle ? shell.shellConfig.idle : ({})
  readonly property int timeoutSeconds: {
    var n = Number(root.idleConfig.displayOff)
    if (!isFinite(n) || n <= 0) return root.defaultTimeoutSeconds
    return Math.floor(n)
  }

  property bool stayAwake: false
  property bool stayAwakeLoaded: false
  property bool blanked: false

  function logEvent(event) {
    console.log("omarchy display-off " + new Date().toISOString() + " " + event)
  }

  function blank() {
    if (root.blanked || blankProcess.running) return
    root.blanked = true
    logEvent("blank after " + root.timeoutSeconds + "s idle")
    blankProcess.running = true
  }

  function wake(reason) {
    if (!root.blanked) return
    root.blanked = false
    logEvent("wake: " + reason)
    if (!wakeProcess.running) wakeProcess.running = true
  }

  onStayAwakeChanged: if (root.stayAwake) root.wake("stay-awake")

  IdleMonitor {
    id: idleMonitor
    enabled: root.stayAwakeLoaded && !root.stayAwake
    timeout: root.timeoutSeconds
    respectInhibitors: true
    onIsIdleChanged: isIdle ? root.blank() : root.wake("activity")
  }

  Process {
    id: blankProcess
    command: ["bash", "-lc", "omarchy-brightness-keyboard off; omarchy-brightness-display off"]
  }

  Process {
    id: wakeProcess
    command: ["bash", "-lc", "omarchy-system-wake"]
  }

  // Mirror the Stay Awake indicator so toggling it also suspends blanking.
  Process {
    id: stayAwakeProbe
    command: ["bash", "-c", "if [[ -f $HOME/.local/state/omarchy/indicators/stay-awake ]]; then echo yes; else echo no; fi"]
    stdout: SplitParser {
      onRead: function(line) {
        root.stayAwake = String(line).trim() === "yes"
        root.stayAwakeLoaded = true
      }
    }
    onExited: stayAwakeWatcher.reload()
  }

  FileView {
    id: stayAwakeWatcher
    path: root.stayAwakeStateDir
    watchChanges: true
    printErrors: false
    onFileChanged: if (!stayAwakeProbe.running) stayAwakeProbe.running = true
  }

  Component.onCompleted: {
    logEvent("service-ready timeout=" + root.timeoutSeconds)
    stayAwakeProbe.running = true
  }
}
