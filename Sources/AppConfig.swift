import Foundation
import CoreFoundation

/// 用户偏好的唯一入口；系统登录项状态由 LoginItemController 管理。
final class AppConfig {
    private let defaults: UserDefaults
    private enum Key {
        static let dimmingEnabled = "dimmingEnabled"
        static let dimmingPercent = "dimmingPercent"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var dimmingEnabled: Bool {
        get {
            guard let value = defaults.object(forKey: Key.dimmingEnabled) as? NSNumber,
                  CFGetTypeID(value) == CFBooleanGetTypeID() else { return true }
            return value.boolValue
        }
        set { defaults.set(newValue, forKey: Key.dimmingEnabled) }
    }

    var dimmingPercent: Int {
        get {
            guard let value = defaults.object(forKey: Key.dimmingPercent) as? NSNumber,
                  CFGetTypeID(value) != CFBooleanGetTypeID(),
                  value.doubleValue.isFinite else { return 20 }
            return Int(min(100, max(0, value.doubleValue)).rounded())
        }
        set { defaults.set(min(100, max(0, newValue)), forKey: Key.dimmingPercent) }
    }

    var dimmingOpacity: CGFloat { CGFloat(dimmingPercent) / 100 }
}
