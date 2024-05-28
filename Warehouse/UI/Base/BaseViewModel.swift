import SwiftUI
import Combine

@MainActor
class BaseViewModel<Item>: ObservableObject {
    
    @Published var item: Item?
    
    @Published var loading: Bool = false
    
    @Published var serverError: String? = nil
    
    @Published var connectionError: String? = nil
    
    
    private (set) var domain: Domain? = nil
    
    init() {
        item = nil
    }
    
    init(item: Item) {
        self.item = item
    }
    
    func onAppearLoader(domain: Domain, subject: PassSubject<Item>) async {
        subject.send(completion: .finished)
    }
    
    func onAppear(domain: Domain) {
        self.domain = domain
        guard item == nil else { return }
        
        makeRequest {
            await self.onAppearLoader(domain: domain, subject: $0)
        } onData: { item in
            self.item = item
        }
    }
    
    func makeRequest<T>(
        load: @escaping (PassSubject<T>) async -> Void,
        onData: @escaping (T) -> Void
    ) {
        
        if loading {
            return
        }
        
        let subject = PassthroughSubject<DomainResponseOutput<T>, DomainResponseError>()
        
        let detectionCancellable = subject
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: receiveCompletion(completion:),
                receiveValue: {
                    self.receiveValue(result: $0, onData: onData)
                }
            )
        reset()
        
        Task {
            loading = true
            await load(subject)
            loading = false
            detectionCancellable.cancel()
        }
    }
    
    private func receiveCompletion(completion: Subscribers.Completion<DomainResponseError>) {
        if case .failure(let failure) = completion {
            switch failure {
            case .connectionError(info: let info):
                connectionError = info
            case .serverError(let serverError):
                self.serverError = serverErrorDescription(serverError)
            }
        }
    }
    
    private func receiveValue<T>(result: DomainResponseOutput<T>, onData: @escaping (T) -> Void) {
        switch result {
        case .success(let data):
            onData(data)
        }
    }
    
    private func reset() {
        serverError = nil
        connectionError = nil
    }
    
    private func serverErrorDescription(_ serverError: ServerError) -> String {
        switch serverError {
        case .invalidInput:
            "Неверный ввод"
        case .unauthorized:
            "Не авторизован"
        case .notFound:
            "Не найдено"
        case .notAcceptable:
            "Не применимо"
        case .undocumented(let statusCode):
            "Неизвестная (\(statusCode)"
        case .parsingError:
            "Неизвестные данные"
        case .notSet:
            "Адрес сервера не установлен"
        }
    }
    
    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)")
            })
        }
    }
    
    func closeApp() {
        exit(0)
    }
}
