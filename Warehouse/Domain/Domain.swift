import SwiftUI
import Combine
import OpenAPIRuntime

class Domain: ObservableObject {
    
    private var url: URL? = nil
    @Published private var token: String? = nil
    
    var needAuth: Binding<Bool> {
        Binding(
            get: { self.url != nil && self.token == nil },
            set: {_ in }
        )
    }
    
    init() {
        checkResetAuth()
        setupServerURL()
        setupToken()
    }
    
    func getAuth(login: String, password: String, subject: PassSubject<String>) async {
        guard let url = url else {
            urlErrorSend(subject: subject)
            return
        }
        let res = await WarehouseClientAPI(url: url, token: token).getAuth(login: login, password: password)
        if case .success(let token) = res {
            self.token = token
            KeychainHelper.setToken(token: token)
        }
        sendResponse(dataResponse: res, subject: subject)
    }
    
    func getProjects(subject: PassSubject<[Project]>) async {
        guard let url = url else {
            urlErrorSend(subject: subject)
            return
        }
        let data = await WarehouseClientAPI(url: url, token: token).getProjects()
        sendResponse(dataResponse: data, subject: subject)
    }
    
    func getWarehouses(projectId: Int, subject: PassSubject<[Warehouse]>) async {
        guard let url = url else {
            urlErrorSend(subject: subject)
            return
        }
        let data = await WarehouseClientAPI(url: url, token: token).getWarehouses(projectId: projectId)
        sendResponse(dataResponse: data, subject: subject)
    }
    
    func getProducts(
        warehouseId: Int,
        page: Int,
        perPage: Int,
        searchFilter: String?,
        sort: SortType,
        subject: PassSubject<(PaginatedResult, [Product])>
    ) async {
        guard let url = url else {
            urlErrorSend(subject: subject)
            return
        }
        let data = await WarehouseClientAPI(url: url, token: token).getProducts(
            warehouseId: warehouseId,
            page: page,
            perPage: perPage,
            searchFilter: searchFilter,
            sort: sort
        )
        sendResponse(dataResponse: data, subject: subject)
    }
    
    func getProduct(productId: Int, subject: PassSubject<Product>) async {
        guard let url = url else {
            urlErrorSend(subject: subject)
            return
        }
        let data = await WarehouseClientAPI(url: url, token: token).getProduct(productId: productId)
        sendResponse(dataResponse: data, subject: subject)
    }
    
    func postProduct(warehouseId: Int, product: Product, subject: PassSubject<Product>) async {
        guard let url = url else {
            urlErrorSend(subject: subject)
            return
        }
        let data = await WarehouseClientAPI(url: url, token: token).postProduct(warehouseId: warehouseId, product: product)
        sendResponse(dataResponse: data, subject: subject)
    }
    
    func putProduct(product: Product, subject: PassSubject<Product>) async {
        guard let url = url else {
            urlErrorSend(subject: subject)
            return
        }
        let data = await WarehouseClientAPI(url: url, token: token).putProduct(product: product)
        sendResponse(dataResponse: data, subject: subject)
    }
    
    func getPathForProduct(productId: Int, subject: PassSubject<ProductPath>) async {
        guard let url = url else {
            urlErrorSend(subject: subject)
            return
        }
        let data = await WarehouseClientAPI(url: url, token: token).getPathForProduct(productId: productId)
        sendResponse(dataResponse: data, subject: subject)
    }
    
    func encryptId(id: Int, subject: PassSubject<String>) async {
        guard let url = url else {
            urlErrorSend(subject: subject)
            return
        }
        let data = await WarehouseClientAPI(url: url, token: token).encryptId(id: id)
        sendResponse(dataResponse: data, subject: subject)
    }
    
    func decryptId(encrypted: String, subject: PassSubject<Int>) async {
        guard let url = url else {
            urlErrorSend(subject: subject)
            return
        }
        let data = await WarehouseClientAPI(url: url, token: token).decryptId(encrypted: encrypted)
        sendResponse(dataResponse: data, subject: subject)
    }
    
    func getPhoto(productId: Int, subject: PassSubject<Data?>) async {
        guard let url = url else {
            urlErrorSend(subject: subject)
            return
        }
        let dataResponse = await WarehouseClientAPI(url: url, token: token).getPhoto(productId: productId)
        do {
            switch dataResponse {
            case .success(let httpBody):
                if let httpBody = httpBody {
                    let photoData = try await Data(collecting: httpBody, upTo: .max)
                    subject.send(.success(data: photoData))
                } else {
                    subject.send(.success(data: nil))
                }
            case .connectionError(let info):
                subject.send(completion: .failure(.connectionError(info: info)))
            case .serverError(let serverError):
                subject.send(completion: .failure(.serverError(serverError)))
            }
        } catch {
            sendResponse(dataResponse: .serverError(.parsingError), subject: subject)
        }
    }
    
    func postPhoto(productId: Int, photoData: Data, subject: PassSubject<Void>) async {
        guard let url = url else {
            urlErrorSend(subject: subject)
            return
        }
        let data = await WarehouseClientAPI(url: url, token: token).postPhoto(productId: productId, photoData: HTTPBody(photoData))
        sendResponse(dataResponse: data, subject: subject)
    }
    
    func deletePhoto(productId: Int, subject: PassSubject<Void>) async {
        guard let url = url else {
            urlErrorSend(subject: subject)
            return
        }
        
        let data = await WarehouseClientAPI(url: url, token: token).deletePhoto(productId: productId)
        sendResponse(dataResponse: data, subject: subject)
    }
    
    func deleteProduct(productId: Int, subject: PassSubject<Void>) async {
        guard let url = url else {
            urlErrorSend(subject: subject)
            return
        }
        
        let data = await WarehouseClientAPI(url: url, token: token).deleteProduct(productId: productId)
        sendResponse(dataResponse: data, subject: subject)
    }
    
    func setupServerURL() {
        if let serverURL = SettingsBundleHelper.getServerURL() {
            url = URL(string: serverURL)
        } else {
            url = nil
        }
    }
    
    private func checkResetAuth() {
        if SettingsBundleHelper.getResetAuth() {
            KeychainHelper.deleteToken()
            SettingsBundleHelper.setResetAuth(false)
        }
    }
    
    private func sendResponse<T>(dataResponse: DataResponse<T>, subject: PassSubject<T>) {
        switch dataResponse {
        case .success(let data):
            subject.send(.success(data: data))
        case .connectionError(let info):
            subject.send(completion: .failure(.connectionError(info: info)))
        case .serverError(let serverError):
            subject.send(completion: .failure(.serverError(serverError)))
        }
    }
    
    private func urlErrorSend<T>(subject: PassSubject<T>) {
        subject.send(completion: .failure(.serverError(.notSet)))
    }
    
    private func setupToken() {
        token = KeychainHelper.getToken()
    }
    
    private func useTestData() -> Bool {
        return url == nil
    }
}
