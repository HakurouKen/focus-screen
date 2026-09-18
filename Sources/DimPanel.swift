import AppKit

final class DimPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    init(frame: NSRect, opacity: CGFloat) {
        super.init(contentRect: frame, styleMask: [.borderless, .nonactivatingPanel],
                   backing: .buffered, defer: false)
        isReleasedWhenClosed = false
        isOpaque = false
        setOpacity(opacity)
        hasShadow = false
        ignoresMouseEvents = true
        hidesOnDeactivate = false
        isMovable = false
        animationBehavior = .none
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        if #available(macOS 13.0, *) {
            collectionBehavior.insert(.canJoinAllApplications)
        }
        setAccessibilityElement(false)
    }

    func setOpacity(_ opacity: CGFloat) {
        backgroundColor = NSColor.black.withAlphaComponent(min(1, max(0, opacity)))
    }
}
