import Foundation

enum ServerError {
    case invalidInput
    case unauthorized
    case notFound
    case notAcceptable
    case undocumented(statusCode: Int)
    case parsingError
    case notSet
}
