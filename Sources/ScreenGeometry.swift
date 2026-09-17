import Foundation
import CoreGraphics

/// AX 使用主屏左上角原点，AppKit 使用主屏左下角原点。
func appKitFrame(fromAX frame: CGRect, primaryHeight: CGFloat) -> CGRect {
    CGRect(x: frame.minX, y: primaryHeight - frame.maxY,
           width: frame.width, height: frame.height)
}

/// 跨屏窗口取重叠面积最大的屏幕；没有交集时不猜测焦点。
func focusedScreenIndex(window: CGRect, screens: [CGRect]) -> Int? {
    guard !window.isEmpty, !window.isInfinite, !window.isNull else { return nil }
    var result: Int?
    var largest: CGFloat = 0
    for (index, screen) in screens.enumerated() {
        let overlap = window.intersection(screen)
        let area = overlap.isNull ? 0 : overlap.width * overlap.height
        if area > largest {
            largest = area
            result = index
        }
    }
    return result
}
