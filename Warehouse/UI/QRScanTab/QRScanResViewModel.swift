import Foundation

@MainActor
final class QRScanResViewModel: BaseViewModel<Int> {
    
    private let encrypted: String
    
    init(encrypted: String) {
        self.encrypted = encrypted
        
        super.init()
    }
    
    override func onAppearLoader(domain: Domain, subject: PassSubject<Int>) async {
        await domain.decryptId(encrypted: self.encrypted, subject: subject)
    }
}
