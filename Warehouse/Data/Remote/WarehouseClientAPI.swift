import Foundation
import OpenAPIURLSession
import OpenAPIRuntime

struct WarehouseClientAPI: APIDataProtocol {
    
    let url: URL
    
    var token: String?
    
    func getAuth(login: String, password: String) async -> DataResponse<String> {
        await makeRequest {
            try await $0.getAuth(query: .init(login: login, password: password))
        } result: {
            switch $0 {
            case .ok(let res):
                if case .json(let token) = res.body {
                    return .success(data: token)
                } else {
                    return .serverError(.parsingError)
                }
            case .notFound(_):
                return .serverError(.notFound)
            case .undocumented(statusCode: let statusCode, _):
                return .serverError(.undocumented(statusCode: statusCode))
            }
        }
    }
    
    func getProjects() async -> DataResponse<[Project]> {
        await makeRequest {
            try await $0.getProjects()
        } result: {
            switch $0 {
            case .ok(let res):
                if case .json(let projects) = res.body {
                    return .success(data: projects)
                } else {
                    return .serverError(.parsingError)
                }
            case .unauthorized(_):
                return .serverError(.unauthorized)
            case .undocumented(statusCode: let statusCode, _):
                return .serverError(.undocumented(statusCode: statusCode))
            }
        }
    }
    
    func getWarehouses(projectId: Int) async -> DataResponse<[Warehouse]> {
        await makeRequest {
            try await $0.getWarehouses(path: .init(projectId: projectId))
        } result: {
            switch $0 {
            case .ok(let res):
                if case .json(let warehouses) = res.body {
                    return .success(data: warehouses)
                } else {
                    return .serverError(.parsingError)
                }
            case .unauthorized(_):
                return .serverError(.unauthorized)
            case .notFound(_):
                return .serverError(.notFound)
            case .undocumented(statusCode: let statusCode, _):
                return .serverError(.undocumented(statusCode: statusCode))
            }
        }
    }
    
    func getProducts(
        warehouseId: Int,
        page: Int,
        perPage: Int,
        searchFilter: String?,
        sort: SortType
    ) async -> DataResponse<(PaginatedResult, [Product])> {
        await makeRequest {
            try await $0.getProducts(
                path: .init(warehouseId: warehouseId),
                query: .init(page: page, per_page: perPage, searchFilter: searchFilter, sort: sort)
            )
        } result: {
            switch $0 {
            case .ok(let res):
                if case .json(let body) = res.body {
                    return .success(data: (body.value1, body.value2.results!))
                } else {
                    return .serverError(.parsingError)
                }
            case .unauthorized(_):
                return .serverError(.unauthorized)
            case .notFound(_):
                return .serverError(.notFound)
            case .notAcceptable(_):
                return .serverError(.notAcceptable)
            case .undocumented(statusCode: let statusCode, _):
                return .serverError(.undocumented(statusCode: statusCode))
            }
        }
    }
    
    func getProduct(productId: Int) async -> DataResponse<Product> {
        await makeRequest {
            try await $0.getProduct(query: .init(productId: productId))
        } result: {
            switch $0 {
            case .ok(let res):
                if case .json(let product) = res.body {
                    return .success(data: product)
                } else {
                    return .serverError(.parsingError)
                }
            case .unauthorized(_):
                return .serverError(.unauthorized)
            case .notFound(_):
                return .serverError(.notFound)
            case .undocumented(statusCode: let statusCode, _):
                return .serverError(.undocumented(statusCode: statusCode))
            }
        }
    }
    
    func postProduct(warehouseId: Int, product: Product) async -> DataResponse<Product> {
        await makeRequest {
            try await $0.postProduct(
                query: .init(warehouseId: warehouseId),
                body: .json(product)
            )
        } result: {
            switch $0 {
            case .created(let res):
                if case .json(let product) = res.body {
                    return .success(data: product)
                } else {
                    return .serverError(.parsingError)
                }
            case .badRequest(_):
                return .serverError(.invalidInput)
            case .unauthorized(_):
                return .serverError(.unauthorized)
            case .notFound(_):
                return .serverError(.notFound)
            case .undocumented(statusCode: let statusCode, _):
                return .serverError(.undocumented(statusCode: statusCode))
            }
        }
    }
    
    func putProduct(product: Product) async -> DataResponse<Product> {
        await makeRequest {
            try await $0.putProduct(body: .json(product))
        } result: {
            switch $0 {
            case .ok(let res):
                if case .json(let product) = res.body {
                    return .success(data: product)
                } else {
                    return .serverError(.parsingError)
                }
            case .badRequest(_):
                return .serverError(.invalidInput)
            case .unauthorized(_):
                return .serverError(.unauthorized)
            case .notFound(_):
                return .serverError(.notFound)
            case .undocumented(statusCode: let statusCode, _):
                return .serverError(.undocumented(statusCode: statusCode))
            }
        }
    }
    
    func deleteProduct(productId: Int) async -> DataResponse<Void> {
        await makeRequest {
            try await $0.deleteProduct(query: .init(productId: productId))
        } result: {
            switch $0 {
            case .ok(_):
                return .success(data: ())
            case .unauthorized(_):
                return .serverError(.unauthorized)
            case .notFound(_):
                return .serverError(.notFound)
            case .undocumented(statusCode: let statusCode, _):
                return .serverError(.undocumented(statusCode: statusCode))
            case .badRequest(_):
                return .serverError(.invalidInput)
            }
        }
    }
    
    func getPathForProduct(productId: Int) async -> DataResponse<ProductPath> {
        await makeRequest {
            try await $0.getPathForProduct(.init(path: .init(productId: productId)))
        } result: {
            switch $0 {
            case .ok(let res):
                if case .json(let productPath) = res.body {
                    return .success(data: productPath)
                } else {
                    return .serverError(.parsingError)
                }
            case .badRequest(_):
                return .serverError(.invalidInput)
            case .unauthorized(_):
                return .serverError(.unauthorized)
            case .undocumented(statusCode: let statusCode, _):
                return .serverError(.undocumented(statusCode: statusCode))
            }
        }
    }
    
    func encryptId(id: Int) async -> DataResponse<String> {
        await makeRequest {
            try await $0.encryptId(body: .json(id))
        } result: {
            switch $0 {
            case .ok(let res):
                if case .json(let encrypted) = res.body {
                    return .success(data: encrypted)
                } else {
                    return .serverError(.parsingError)
                }
            case .badRequest(_):
                return .serverError(.invalidInput)
            case .unauthorized(_):
                return .serverError(.unauthorized)
            case .undocumented(statusCode: let statusCode, _):
                return .serverError(.undocumented(statusCode: statusCode))
            }
        }
    }
    
    func decryptId(encrypted: String) async -> DataResponse<Int> {
        await makeRequest {
            try await $0.decryptId(body: .json(encrypted))
        } result: {
            switch $0 {
            case .ok(let res):
                if case .json(let id) = res.body {
                    return .success(data: id)
                } else {
                    return .serverError(.parsingError)
                }
            case .badRequest(_):
                return .serverError(.invalidInput)
            case .unauthorized(_):
                return .serverError(.unauthorized)
            case .undocumented(statusCode: let statusCode, _):
                return .serverError(.undocumented(statusCode: statusCode))
            }
        }
    }
    
    func getPhoto(productId: Int) async -> DataResponse<HTTPBody?> {
        await makeRequest {
            try await $0.getPhoto(.init(path: .init(productId: productId)))
        } result: {
            switch $0 {
            case .ok(let res):
                if case .binary(let binary) = res.body {
                    return .success(data: binary)
                } else {
                    return .serverError(.parsingError)
                }
            case .noContent(_):
                return .success(data: nil)
            case .unauthorized(_):
                return .serverError(.unauthorized)
            case .notFound(_):
                return .serverError(.notFound)
            case .undocumented(statusCode: let statusCode, _):
                return .serverError(.undocumented(statusCode: statusCode))
            }
        }
    }
    
    func postPhoto(productId: Int, photoData: HTTPBody) async -> DataResponse<Void> {
        await makeRequest {
            try await $0.postPhoto(path: .init(productId: productId), body: .binary(photoData))
        } result: {
            switch $0 {
            case .ok(_):
                return .success(data: ())
            case .badRequest(_):
                return .serverError(.invalidInput)
            case .unauthorized(_):
                return .serverError(.unauthorized)
            case .notFound(_):
                return .serverError(.notFound)
            case .undocumented(statusCode: let statusCode, _):
                return .serverError(.undocumented(statusCode: statusCode))
            }
        }
    }
    
    func deletePhoto(productId: Int) async -> DataResponse<Void> {
        await makeRequest {
            try await $0.deletePhoto(.init(path: .init(productId: productId)))
        } result: {
            switch $0 {
            case .ok(_):
                return .success(data: ())
            case .badRequest(_):
                return .serverError(.invalidInput)
            case .unauthorized(_):
                return .serverError(.unauthorized)
            case .notFound(_):
                return .serverError(.notFound)
            case .undocumented(statusCode: let statusCode, _):
                return .serverError(.undocumented(statusCode: statusCode))
            }
        }
    }
    
    private func makeRequest<T, R>(request: (Client) async throws -> T, result: (T) -> DataResponse<R>) async -> DataResponse<R> {
        do {
            let client = Client(
                serverURL: url,
                transport: URLSessionTransport(),
                middlewares: [AuthenticationMiddleware(token: token)]
            )
            let response = try await request(client)
            return result(response)
        } catch {
            return .connectionError(info: error.localizedDescription)
        }
    }
}
