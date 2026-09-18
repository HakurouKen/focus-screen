import Foundation

@main
struct RefreshSchedulerTests {
    static func main() {
        let scheduler = RefreshScheduler()
        var calls = 0
        scheduler.action = { calls += 1 }

        for _ in 0..<100 { scheduler.request() }
        assert(calls == 0, "AX 回调不应同步执行读取")
        pump(for: 0.12)
        assert(calls == 1, "一轮通知应合并为一次读取")

        calls = 0
        let producer = Timer(timeInterval: 0.01, repeats: true) { _ in scheduler.request() }
        RunLoop.main.add(producer, forMode: .common)
        pump(for: 0.35)
        producer.invalidate()
        scheduler.cancel()
        assert(calls >= 2, "持续拖动时不能等到事件停止才刷新")
        assert(calls <= 8, "密集事件应限制刷新频率")

        calls = 0
        scheduler.request()
        scheduler.refreshImmediately()
        assert(calls == 1, "系统事件应立即刷新")
        pump(for: 0.25)
        assert(calls == 2, "取消旧请求，并且仅补一次过渡状态校验")

        calls = 0
        scheduler.refreshImmediately()
        scheduler.request()
        scheduler.cancel()
        pump(for: 0.25)
        assert(calls == 1, "暂停时应取消 AX 请求和延迟校验")

        calls = 0
        scheduler.request()
        pump(for: 0.12)
        assert(calls == 1, "取消后应能重新调度")

        calls = 0
        var temporary: RefreshScheduler? = RefreshScheduler()
        temporary?.action = { calls += 1 }
        temporary?.request()
        temporary = nil
        pump(for: 0.12)
        assert(calls == 0, "释放调度器后不得再执行读取")
        print("通过 6 组刷新合并、持续事件、立即刷新、取消与释放场景")
    }

    private static func pump(for interval: TimeInterval) {
        RunLoop.main.run(until: Date().addingTimeInterval(interval))
    }
}
