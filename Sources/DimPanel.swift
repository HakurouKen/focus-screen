import AppKit

final class DimPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    init(frame: NSRect) {
        super.init(contentRect: frame, styleMask: [.borderless, .nonactivatingPanel],
                   backing: .buffered, defer: false)
        isReleasedWhenClosed = false
        isOpaque = false
        backgroundColor = NSColor.black.withAlphaComponent(0.2)
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
}
