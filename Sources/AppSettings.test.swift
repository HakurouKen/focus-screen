import AppKit
import ServiceManagement

private final class FakeLoginItemService: LoginItemService {
    var status: SMAppService.Status = .notRegistered
    var registrationResult: SMAppService.Status = .enabled
    var failure: Error?
    var registrations = 0
    var unregistrations = 0

    func register() throws {
        registrations += 1
        if let failure { throw failure }
        status = registrationResult
    }

    func unregister() throws {
        unregistrations += 1
        if let failure { throw failure }
        status = .notRegistered
    }
}

@main
struct AppSettingsTests {
    static func main() throws {
        testConfig()
        try testLoginItems()
        testControls()
        print("通过配置持久化与边界、登录项状态与失败、滑块与遮罩更新测试")
    }

    private static func testConfig() {
        let suite = "local.focus-screen.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let config = AppConfig(defaults: defaults)
        assert(config.dimmingEnabled && config.dimmingPercent == 20)
        config.dimmingEnabled = false
        config.dimmingPercent = 73
        let reloaded = AppConfig(defaults: UserDefaults(suiteName: suite)!)
        assert(!reloaded.dimmingEnabled && reloaded.dimmingPercent == 73)
        assert(abs(reloaded.dimmingOpacity - 0.73) < 0.0001)
        config.dimmingPercent = 0
        assert(config.dimmingPercent == 0 && !config.dimmingEnabled)
        config.dimmingEnabled = true
        assert(config.dimmingPercent == 0 && config.dimmingEnabled)
        config.dimmingPercent = 100
        assert(config.dimmingOpacity == 1)
        config.dimmingPercent = Int.max
        assert(config.dimmingPercent == 100)
        config.dimmingPercent = Int.min
        assert(config.dimmingPercent == 0)
        for invalid: Any in ["broken", true, Double.nan, Double.infinity] {
            defaults.set(invalid, forKey: "dimmingPercent")
            assert(config.dimmingPercent == 20)
        }
        defaults.set(-10, forKey: "dimmingPercent")
        assert(config.dimmingPercent == 0)
        defaults.set(200, forKey: "dimmingPercent")
        assert(config.dimmingPercent == 100)
        defaults.set(36.7, forKey: "dimmingPercent")
        assert(config.dimmingPercent == 37)
        defaults.set("broken", forKey: "dimmingEnabled")
        assert(config.dimmingEnabled)
    }

    private static func testLoginItems() throws {
        let service = FakeLoginItemService()
        let controller = LoginItemController(service: service)
        assert(controller.status == .notRegistered && service.registrations == 0)
        try controller.setEnabled(true)
        assert(controller.status == .enabled && service.registrations == 1)
        try controller.setEnabled(true)
        assert(service.registrations == 1)
        // 系统设置中的外部修改必须立即反映到查询结果。
        service.status = .requiresApproval
        assert(controller.status == .requiresApproval)
        try controller.setEnabled(true)
        assert(service.registrations == 1)
        try controller.setEnabled(false)
        assert(controller.status == .notRegistered && service.unregistrations == 1)
        try controller.setEnabled(false)
        assert(service.unregistrations == 1)
        service.registrationResult = .requiresApproval
        try controller.setEnabled(true)
        assert(controller.status == .requiresApproval)
        service.failure = NSError(domain: "LoginItemTests", code: 1)
        do {
            try controller.setEnabled(false)
            assertionFailure("注销失败应向调用方报告")
        } catch {
            assert(controller.status == .requiresApproval)
        }
        service.status = .notRegistered
        do {
            try controller.setEnabled(true)
            assertionFailure("注册失败应向调用方报告")
        } catch {
            assert(controller.status == .notRegistered)
        }
        service.failure = nil
        service.status = .notFound
        assert(controller.status == .notFound)
    }

    private static func testControls() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        let view = DimmingMenuView(percent: 20)
        let slider = view.subviews.compactMap { $0 as? NSSlider }.first!
        let panel = DimPanel(frame: NSRect(x: 0, y: 0, width: 100, height: 100), opacity: 0.2)
        defer { panel.close() }
        assert(slider.isContinuous && slider.minValue == 0 && slider.maxValue == 100)
        var changes: [Int] = []
        view.onChange = { percent in
            changes.append(percent)
            panel.setOpacity(CGFloat(percent) / 100)
        }
        for percent in [0, 37, 100] {
            slider.integerValue = percent
            _ = slider.sendAction(slider.action, to: slider.target)
            assert(abs(panel.backgroundColor!.alphaComponent - CGFloat(percent) / 100) < 0.0001)
            assert(view.subviews.compactMap { $0 as? NSTextField }.contains { $0.stringValue == "\(percent)%" })
        }
        assert(changes == [0, 37, 100])
        assert(panel.ignoresMouseEvents && !panel.canBecomeKey && !panel.canBecomeMain)
        assert(!panel.isVisible, "修改透明度不应显示暂停状态下的遮罩")
        view.setPercent(20)
        assert(slider.integerValue == 20 && changes.count == 3)
        slider.doubleValue = 36.7
        _ = slider.sendAction(slider.action, to: slider.target)
        assert(slider.integerValue == 37 && changes.last == 37)
        _ = slider.accessibilityPerformIncrement()
        assert(slider.integerValue == 38 && changes.last == 38)
        let leftArrow = NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: [],
            timestamp: 0, windowNumber: 0, context: nil, characters: "\u{f702}",
            charactersIgnoringModifiers: "\u{f702}", isARepeat: false, keyCode: 123)!
        slider.keyDown(with: leftArrow)
        assert(slider.integerValue == 37 && changes.last == 37)
        view.setPercent(0)
        _ = slider.accessibilityPerformDecrement()
        assert(slider.integerValue == 0 && changes.last == 0)
        view.setPercent(100)
        _ = slider.accessibilityPerformIncrement()
        assert(slider.integerValue == 100 && changes.last == 100)
    }
}
