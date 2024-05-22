import Foundation

struct KeychainHelper {
    
    static func setToken(token: String) {
        let tokenData = token.data(using: .utf8)!
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: tokenData
        ]
        
        SecItemAdd(addQuery as CFDictionary, nil)
    }
    
    static func getToken() -> String? {
        let getQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getQuery as CFDictionary, &item)
        guard let result = item as? NSDictionary, let passwordData = result[kSecValueData] as? Data else {
            return nil
        }
        return String(decoding: passwordData, as: UTF8.self)
    }
    
    static func deleteToken() {
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]
        
        SecItemDelete(deleteQuery as CFDictionary)
    }
}
