import Foundation

enum DataResponse<T> {
    case success(data: T)
    case connectionError(info: String)
    case serverError(ServerError)
}
