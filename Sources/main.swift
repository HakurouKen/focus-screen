import AppKit
import ApplicationServices

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private let stateItem = NSMenuItem(title: "正在检测焦点…", action: nil, keyEquivalent: "")
    private let toggleItem = NSMenuItem(title: "启用屏幕调暗", action: #selector(toggle), keyEquivalent: "")
    private let config = AppConfig()
    private let loginItem = LoginItemController()
    private let loginItemMenu = NSMenuItem(title: "登录时自动启动", action: #selector(toggleLoginItem), keyEquivalent: "")
    private let loginSettingsMenu = NSMenuItem(title: "在系统设置中允许…", action: #selector(openLoginSettings), keyEquivalent: "")
    private lazy var dimmingView = DimmingMenuView(percent: config.dimmingPercent)
    private var panels: [DimPanel] = []
    private var frames: [CGRect] = []
    private var timer: Timer?
    private let reader = FocusReader()
    private let scheduler = RefreshScheduler()
    private var displayedScreen: Int?
    private var needsPanelUpdate = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "display.2", accessibilityDescription: "Focus Screen")
        let menu = NSMenu()
        menu.delegate = self
        stateItem.isEnabled = false
        menu.addItem(stateItem)
        menu.addItem(.separator())
        toggleItem.target = self
        toggleItem.state = config.dimmingEnabled ? .on : .off
        menu.addItem(toggleItem)
        let dimmingItem = NSMenuItem()
        dimmingItem.view = dimmingView
        dimmingView.onChange = { [weak self] percent in
            guard let self else { return }
            self.config.dimmingPercent = percent
            self.panels.forEach { $0.setOpacity(self.config.dimmingOpacity) }
        }
        menu.addItem(dimmingItem)
        menu.addItem(.separator())
        loginItemMenu.target = self
        loginSettingsMenu.target = self
        menu.addItem(loginItemMenu)
        menu.addItem(loginSettingsMenu)
        updateLoginItemMenu()
        menu.addItem(.separator())
        let permission = NSMenuItem(title: "授权辅助功能…", action: #selector(openPermissions), keyEquivalent: "")
        permission.target = self
        menu.addItem(permission)
        menu.addItem(.separator())
        let quit = NSMenuItem(title: "退出 Focus Screen", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
        statusItem.menu = menu
        scheduler.action = { [weak self] in self?.refresh() }
        reader.onChange = { [weak self] in self?.scheduler.request() }
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(systemChanged),
            name: NSWorkspace.didActivateApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(systemChanged),
            name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(systemChanged),
            name: NSWorkspace.didWakeNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(systemChanged),
            name: NSWorkspace.didTerminateApplicationNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(systemChanged),
            name: NSApplication.didChangeScreenParametersNotification, object: nil)
        refresh()
    }

    @objc private func refresh() {
        defer { needsPanelUpdate = false }
        let screens = NSScreen.screens
        let currentFrames = screens.map(\.frame)
        if currentFrames != frames {
            panels.forEach { $0.close() }
            frames = currentFrames
            panels = frames.map { DimPanel(frame: $0, opacity: config.dimmingOpacity) }
            displayedScreen = nil
        }
        guard config.dimmingEnabled, screens.count > 1 else {
            reader.stopObserving()
            setPollingInterval(nil)
            clear(config.dimmingEnabled ? "单屏幕，无需调暗" : "已暂停")
            return
        }
        guard AXIsProcessTrusted() else {
            reader.stopObserving()
            setPollingInterval(2)
            clear("需要辅助功能授权")
            return
        }
        let axFrame = reader.windowFrame()
        setPollingInterval(reader.hasCompleteObservation && axFrame != nil ? 2 : 0.25)
        guard let primary = screens.first, let axFrame,
              let index = focusedScreenIndex(
                window: appKitFrame(fromAX: axFrame, primaryHeight: primary.frame.height),
                screens: frames) else {
            clear("未识别到焦点窗口")
            return
        }
        stateItem.title = "焦点：\(screens[index].localizedName)"
        statusItem.button?.toolTip = stateItem.title
        guard displayedScreen != index || needsPanelUpdate else { return }
        displayedScreen = index
        for (offset, panel) in panels.enumerated() {
            if offset == index { panel.orderOut(nil) }
            else { panel.orderFrontRegardless() }
        }
    }

    private func clear(_ message: String) {
        if displayedScreen != nil { panels.forEach { $0.orderOut(nil) } }
        displayedScreen = nil
        stateItem.title = message
        statusItem.button?.toolTip = message
    }

    private func setPollingInterval(_ interval: TimeInterval?) {
        guard timer?.timeInterval != interval else { return }
        timer?.invalidate()
        timer = nil
        guard let interval else { return }
        let timer = Timer(timeInterval: interval, target: self, selector: #selector(refresh),
                          userInfo: nil, repeats: true)
        timer.tolerance = interval == 2 ? 0.2 : 0.05
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    @objc private func systemChanged() {
        // 即使焦点屏幕没变，Space 切换后也需重新确认遮罩的窗口顺序。
        needsPanelUpdate = true
        scheduler.refreshImmediately()
    }

    @objc private func toggle() {
        config.dimmingEnabled.toggle()
        toggleItem.state = config.dimmingEnabled ? .on : .off
        scheduler.cancel()
        refresh()
    }

    func menuWillOpen(_ menu: NSMenu) {
        updateLoginItemMenu()
    }

    private func updateLoginItemMenu() {
        let status = loginItem.status
        loginItemMenu.state = status == .enabled ? .on : status == .requiresApproval ? .mixed : .off
        switch status {
        case .enabled, .notRegistered:
            loginItemMenu.title = "登录时自动启动"
        case .requiresApproval:
            loginItemMenu.title = "登录时自动启动（待允许）"
        case .notFound:
            loginItemMenu.title = "登录时自动启动（未找到应用）"
        @unknown default:
            loginItemMenu.title = "登录时自动启动（状态未知）"
        }
        loginSettingsMenu.isHidden = status != .requiresApproval
    }

    @objc private func toggleLoginItem() {
        let status = loginItem.status
        do {
            try loginItem.setEnabled(status != .enabled && status != .requiresApproval)
            updateLoginItemMenu()
            if loginItem.status == .requiresApproval {
                showLoginItemMessage("需要允许登录时自动启动", detail: "请在系统设置的登录项中允许 Focus Screen。待允许状态下，再次点击开关可取消注册。")
            }
        } catch {
            updateLoginItemMenu()
            showLoginItemMessage("无法更改登录时自动启动", detail: error.localizedDescription)
        }
    }

    private func showLoginItemMessage(_ title: String, detail: String) {
        // 菜单动作结束后再显示提示，避免嵌套菜单跟踪循环。
        DispatchQueue.main.async { [weak self] in
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = detail
            alert.addButton(withTitle: "好")
            alert.addButton(withTitle: "打开登录项设置")
            NSApp.activate(ignoringOtherApps: true)
            if alert.runModal() == .alertSecondButtonReturn { self?.loginItem.openSettings() }
        }
    }

    @objc private func openLoginSettings() { loginItem.openSettings() }

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
        scheduler.cancel()
        reader.stopObserving()
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
