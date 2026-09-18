import AppKit
import ApplicationServices

final class FocusReader {
    var onChange: (() -> Void)?
    private(set) var hasCompleteObservation = false
    private var observer: AXObserver?
    private var application: AXUIElement?
    private var observedWindow: AXUIElement?
    private var processIdentifier: pid_t?
    private var applicationObserved = false
    private var lastBindingAttempt = Date.distantPast
    private let windowNotifications = [kAXMovedNotification, kAXResizedNotification,
        kAXUIElementDestroyedNotification, kAXWindowMiniaturizedNotification,
        kAXWindowDeminiaturizedNotification]

    func windowFrame() -> CGRect? {
        guard AXIsProcessTrusted(),
              let app = NSWorkspace.shared.frontmostApplication,
              app.processIdentifier != ProcessInfo.processInfo.processIdentifier else {
            stopObserving()
            return nil
        }
        // 注册失败可能是应用暂时无响应，每两秒允许重试一次。
        if processIdentifier != app.processIdentifier ||
            (!hasCompleteObservation && Date().timeIntervalSince(lastBindingAttempt) >= 2) {
            bindApplication(app.processIdentifier)
        }
        guard let application,
              let rawWindow = attribute(application, kAXFocusedWindowAttribute),
              CFGetTypeID(rawWindow) == AXUIElementGetTypeID() else {
            bindWindow(nil)
            return nil
        }
        let window = rawWindow as! AXUIElement
        bindWindow(window)
        guard let rawPosition = attribute(window, kAXPositionAttribute),
              let rawSize = attribute(window, kAXSizeAttribute),
              CFGetTypeID(rawPosition) == AXValueGetTypeID(),
              CFGetTypeID(rawSize) == AXValueGetTypeID() else { return nil }
        let positionValue = rawPosition as! AXValue
        let sizeValue = rawSize as! AXValue
        guard AXValueGetType(positionValue) == .cgPoint,
              AXValueGetType(sizeValue) == .cgSize else { return nil }
        var position = CGPoint.zero
        var size = CGSize.zero
        guard AXValueGetValue(positionValue, .cgPoint, &position),
              AXValueGetValue(sizeValue, .cgSize, &size),
              position.x.isFinite, position.y.isFinite,
              size.width.isFinite, size.height.isFinite,
              size.width > 0, size.height > 0 else { return nil }
        return CGRect(origin: position, size: size)
    }

    func stopObserving() {
        if let observer {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(observer), .commonModes)
        }
        observer = nil
        application = nil
        observedWindow = nil
        processIdentifier = nil
        applicationObserved = false
        hasCompleteObservation = false
    }

    private func bindApplication(_ pid: pid_t) {
        stopObserving()
        lastBindingAttempt = Date()
        processIdentifier = pid
        let element = AXUIElementCreateApplication(pid)
        AXUIElementSetMessagingTimeout(element, 0.1)
        application = element
        var created: AXObserver?
        let result = AXObserverCreate(pid, { _, element, notification, context in
            guard let context else { return }
            let reader = Unmanaged<FocusReader>.fromOpaque(context).takeUnretainedValue()
            // 已销毁的元素不能再传给 AX API；其旧注册随 observer 释放。
            if notification as String == kAXUIElementDestroyedNotification,
               let window = reader.observedWindow, CFEqual(element, window) {
                reader.observedWindow = nil
                reader.hasCompleteObservation = false
            }
            reader.onChange?()
        }, &created)
        guard result == .success, let created else { return }
        observer = created
        applicationObserved = register(kAXFocusedWindowChangedNotification, on: element)
        CFRunLoopAddSource(CFRunLoopGetMain(), AXObserverGetRunLoopSource(created), .commonModes)
    }

    private func bindWindow(_ window: AXUIElement?) {
        if let window, let observedWindow, CFEqual(window, observedWindow) { return }
        if let observer, let observedWindow {
            for name in windowNotifications {
                AXObserverRemoveNotification(observer, observedWindow, name as CFString)
            }
        }
        observedWindow = window
        hasCompleteObservation = false
        guard let window else { return }
        AXUIElementSetMessagingTimeout(window, 0.1)
        // 不短路注册，保留应用所支持的每一种通知。
        let results = windowNotifications.map { register($0, on: window) }
        hasCompleteObservation = applicationObserved && results.allSatisfy { $0 }
    }

    private func register(_ name: String, on element: AXUIElement) -> Bool {
        guard let observer else { return false }
        let result = AXObserverAddNotification(observer, element, name as CFString,
            Unmanaged.passUnretained(self).toOpaque())
        return result == .success || result == .notificationAlreadyRegistered
    }

    deinit { stopObserving() }

    private func attribute(_ element: AXUIElement, _ name: String) -> CFTypeRef? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success else {
            return nil
        }
        return value
    }
}
