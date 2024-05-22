import Foundation

struct SettingsBundleHelper {
    
    private static let ServerURLKey = "server_url_preference"
    
    private static let ResetAuthSwitchKey = "reset_auth_switch_preference"
    
    static func getServerURL() -> String? {
        return UserDefaults.standard.string(forKey: ServerURLKey)
    }
    
    static func getResetAuth() -> Bool {
        return UserDefaults.standard.bool(forKey: ResetAuthSwitchKey)
    }
    
    static func setResetAuth(_ val: Bool) {
        UserDefaults.standard.setValue(val, forKey: ResetAuthSwitchKey)
    }
}
