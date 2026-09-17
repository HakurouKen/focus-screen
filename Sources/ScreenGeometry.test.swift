import Foundation
import CoreGraphics

@main
struct ScreenGeometryTests {
    static func main() {
        let primary = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let left = CGRect(x: -1920, y: 0, width: 1920, height: 1080)
        let above = CGRect(x: 0, y: 1080, width: 1920, height: 1080)
        let screens = [primary, left, above]
        assert(appKitFrame(fromAX: CGRect(x: -1920, y: 0, width: 1920, height: 1080),
                           primaryHeight: 1080) == left)
        assert(appKitFrame(fromAX: CGRect(x: 0, y: -1080, width: 1920, height: 1080),
                           primaryHeight: 1080) == above)
        assert(focusedScreenIndex(window: primary, screens: screens) == 0)
        assert(focusedScreenIndex(window: left, screens: screens) == 1)
        assert(focusedScreenIndex(window: above, screens: screens) == 2)
        assert(focusedScreenIndex(window: CGRect(x: -100, y: 0, width: 400, height: 600), screens: screens) == 0)
        assert(focusedScreenIndex(window: CGRect(x: 5000, y: 0, width: 100, height: 100), screens: screens) == nil)
        assert(focusedScreenIndex(window: .zero, screens: screens) == nil)
        assert(focusedScreenIndex(window: primary, screens: []) == nil)
        print("通过 9 项屏幕坐标与焦点归属断言")
    }
}
