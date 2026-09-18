import AppKit

private final class PercentageSlider: NSSlider {
    // 保持平滑轨道，方向键和辅助功能操作统一按 1% 步进。
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123, 125: _ = step(-1)
        case 124, 126: _ = step(1)
        default: super.keyDown(with: event)
        }
    }

    override func accessibilityPerformIncrement() -> Bool { step(1) }
    override func accessibilityPerformDecrement() -> Bool { step(-1) }

    private func step(_ delta: Double) -> Bool {
        guard isEnabled else { return false }
        doubleValue = min(maxValue, max(minValue, doubleValue.rounded() + delta))
        return sendAction(action, to: target)
    }
}

/// 自定义菜单行保留原生滑块行为，拖动过程中不关闭菜单。
final class DimmingMenuView: NSView {
    private let valueLabel = NSTextField(labelWithString: "")
    private let slider = PercentageSlider(value: 20, minValue: 0, maxValue: 100, target: nil, action: nil)
    var onChange: ((Int) -> Void)?

    init(percent: Int) {
        super.init(frame: NSRect(x: 0, y: 0, width: 260, height: 64))
        let title = NSTextField(labelWithString: "调暗程度")
        title.frame = NSRect(x: 20, y: 38, width: 160, height: 18)
        title.font = .menuFont(ofSize: 0)
        addSubview(title)
        valueLabel.frame = NSRect(x: 188, y: 38, width: 52, height: 18)
        valueLabel.alignment = .right
        valueLabel.font = .monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        addSubview(valueLabel)
        slider.altIncrementValue = 1
        slider.frame = NSRect(x: 18, y: 8, width: 224, height: 24)
        slider.isContinuous = true
        slider.target = self
        slider.action = #selector(sliderChanged)
        slider.setAccessibilityLabel("其他屏幕的调暗程度，百分比")
        slider.toolTip = "数值越大，其他屏幕越暗。0% 不调暗，100% 全黑。"
        addSubview(slider)
        setPercent(percent)
    }

    required init?(coder: NSCoder) { nil }

    func setPercent(_ percent: Int) {
        let value = min(100, max(0, percent))
        slider.integerValue = value
        valueLabel.stringValue = "\(value)%"
    }

    @objc private func sliderChanged() {
        let percent = Int(slider.doubleValue.rounded())
        setPercent(percent)
        onChange?(percent)
    }
}
