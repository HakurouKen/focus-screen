import AppKit
import ApplicationServices

struct FocusReader {
    func windowFrame() -> CGRect? {
        guard AXIsProcessTrusted(),
              let app = NSWorkspace.shared.frontmostApplication,
              app.processIdentifier != ProcessInfo.processInfo.processIdentifier else { return nil }
        let element = AXUIElementCreateApplication(app.processIdentifier)
        // 限制无响应应用的 AX 查询等待时间。
        AXUIElementSetMessagingTimeout(element, 0.1)
        guard let rawWindow = attribute(element, kAXFocusedWindowAttribute),
              CFGetTypeID(rawWindow) == AXUIElementGetTypeID() else { return nil }
        let window = rawWindow as! AXUIElement
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

    private func attribute(_ element: AXUIElement, _ name: String) -> CFTypeRef? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success else {
            return nil
        }
        return value
    }
}
