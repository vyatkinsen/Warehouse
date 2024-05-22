import Foundation

@MainActor
final class AuthViewModel: BaseViewModel<Void> {
    
    func auth(login: String, password: String, domain: Domain) {
        makeRequest {
            await domain.getAuth(login: login, password: password, subject: $0)
        } onData: { _ in
            
        }
    }
}
