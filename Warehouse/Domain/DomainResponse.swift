import Foundation
import Combine

enum DomainResponseOutput<T> {
    case success(data: T)
}

enum DomainResponseError: Error {
    case connectionError(info: String)
    case serverError(ServerError)
}

typealias PassSubject<T> = PassthroughSubject<DomainResponseOutput<T>, DomainResponseError>
