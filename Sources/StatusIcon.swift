import AppKit

/// 固定的并排双屏品牌图标；运行状态由菜单文字与悬停提示表达。
enum StatusIcon {
    static func makeImage() -> NSImage {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { _ in
            NSColor.black.set()
            let left = NSBezierPath(roundedRect: NSRect(x: 0.75, y: 6, width: 7.5, height: 6),
                                    xRadius: 1, yRadius: 1)
            left.lineWidth = 1
            left.stroke()
            NSBezierPath(roundedRect: NSRect(x: 9.75, y: 6, width: 7.5, height: 6),
                         xRadius: 1, yRadius: 1).fill()

            let stands = NSBezierPath()
            stands.lineWidth = 1
            stands.lineCapStyle = .round
            for center in [CGFloat(4.5), CGFloat(13.5)] {
                stands.move(to: NSPoint(x: center, y: 6))
                stands.line(to: NSPoint(x: center, y: 3.75))
                stands.move(to: NSPoint(x: center - 2.25, y: 3.75))
                stands.line(to: NSPoint(x: center + 2.25, y: 3.75))
            }
            stands.stroke()
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "Sidelit"
        return image
    }
}
