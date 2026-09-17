import AppKit
import ApplicationServices

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let stateItem = NSMenuItem(title: "正在检测焦点…", action: nil, keyEquivalent: "")
    private let toggleItem = NSMenuItem(title: "启用屏幕调暗", action: #selector(toggle), keyEquivalent: "")
    private var enabled = true
    private var panels: [DimPanel] = []
    private var frames: [CGRect] = []
    private var timer: Timer?
    private let reader = FocusReader()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "display.2", accessibilityDescription: "Focus Screen")
        let menu = NSMenu()
        stateItem.isEnabled = false
        menu.addItem(stateItem)
        menu.addItem(.separator())
        toggleItem.target = self
        toggleItem.state = .on
        menu.addItem(toggleItem)
        let permission = NSMenuItem(title: "授权辅助功能…", action: #selector(openPermissions), keyEquivalent: "")
        permission.target = self
        menu.addItem(permission)
        menu.addItem(.separator())
        let quit = NSMenuItem(title: "退出 Focus Screen", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
        statusItem.menu = menu
        // 定时读取兼容不发送 AX 焦点通知的应用，菜单展开时也继续更新。
        let timer = Timer(timeInterval: 0.25, target: self, selector: #selector(refresh),
                          userInfo: nil, repeats: true)
        timer.tolerance = 0.05
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(refresh),
            name: NSWorkspace.didActivateApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(refresh),
            name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh),
            name: NSApplication.didChangeScreenParametersNotification, object: nil)
        refresh()
    }

    @objc private func refresh() {
        let screens = NSScreen.screens
        let currentFrames = screens.map(\.frame)
        if currentFrames != frames {
            panels.forEach { $0.close() }
            frames = currentFrames
            panels = frames.map { DimPanel(frame: $0) }
        }
        guard enabled else { clear("已暂停"); return }
        guard AXIsProcessTrusted() else { clear("需要辅助功能授权"); return }
        guard screens.count > 1 else { clear("单屏幕，无需调暗"); return }
        guard let primary = screens.first, let axFrame = reader.windowFrame(),
              let index = focusedScreenIndex(
                window: appKitFrame(fromAX: axFrame, primaryHeight: primary.frame.height),
                screens: frames) else {
            clear("未识别到焦点窗口")
            return
        }
        stateItem.title = "焦点：\(screens[index].localizedName)"
        statusItem.button?.toolTip = stateItem.title
        for (offset, panel) in panels.enumerated() {
            if offset == index { panel.orderOut(nil) }
            else { panel.orderFrontRegardless() }
        }
    }

    private func clear(_ message: String) {
        panels.forEach { $0.orderOut(nil) }
        stateItem.title = message
        statusItem.button?.toolTip = message
    }

    @objc private func toggle() {
        enabled.toggle()
        toggleItem.state = enabled ? .on : .off
        refresh()
    }

    @objc private func openPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func quit() { NSApp.terminate(nil) }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
        panels.forEach { $0.close() }
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
