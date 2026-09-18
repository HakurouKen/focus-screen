import Foundation

/// 合并一轮密集通知，保留末次状态；持续拖动也会每 50ms 刷新。
final class RefreshScheduler {
    private var pending: Timer?
    private var settling: Timer?
    var action: (() -> Void)?

    func request() {
        guard pending == nil else { return }
        pending = schedule(after: 0.05) { [weak self] in
            self?.pending = nil
            self?.action?()
        }
    }

    func refreshImmediately() {
        cancel()
        action?()
        // Space、全屏及唤醒通知可能早于 AX 窗口状态完成更新。
        settling = schedule(after: 0.15) { [weak self] in
            self?.settling = nil
            self?.pending?.invalidate()
            self?.pending = nil
            self?.action?()
        }
    }

    func cancel() {
        pending?.invalidate()
        settling?.invalidate()
        pending = nil
        settling = nil
    }

    private func schedule(after interval: TimeInterval, action: @escaping () -> Void) -> Timer {
        let timer = Timer(timeInterval: interval, repeats: false) { _ in action() }
        RunLoop.main.add(timer, forMode: .common)
        return timer
    }

    deinit { cancel() }
}
