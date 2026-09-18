import ServiceManagement

/// 隔离系统副作用，以便测试注册失败及用户从系统设置修改状态的场景。
protocol LoginItemService {
    var status: SMAppService.Status { get }
    func register() throws
    func unregister() throws
}

extension SMAppService: LoginItemService {}

final class LoginItemController {
    private let service: LoginItemService

    init(service: LoginItemService = SMAppService.mainApp) {
        self.service = service
    }

    // 不缓存，也不向 UserDefaults 写入第二份状态。
    var status: SMAppService.Status { service.status }

    func setEnabled(_ enabled: Bool) throws {
        let current = status
        if enabled {
            guard current != .enabled && current != .requiresApproval else { return }
            try service.register()
        } else {
            guard current == .enabled || current == .requiresApproval else { return }
            try service.unregister()
        }
    }

    func openSettings() { SMAppService.openSystemSettingsLoginItems() }
}
