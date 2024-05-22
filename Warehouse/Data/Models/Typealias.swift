import Foundation

typealias Project = Components.Schemas.Project

typealias Warehouse = Components.Schemas.Warehouse

typealias Product = Components.Schemas.Product

typealias ProductPath = Components.Schemas.ProductPath

typealias PaginatedResult = Components.Schemas.PaginatedResult

typealias SortType = Operations.getProducts.Input.Query.sortPayload


extension Product: Identifiable {}
