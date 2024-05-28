import Foundation
import OpenAPIRuntime

protocol APIDataProtocol {
    func getAuth(login: String, password: String) async -> DataResponse<String>
    
    func getProjects() async -> DataResponse<[Project]>
    
    func getWarehouses(projectId: Int) async -> DataResponse<[Warehouse]>
    
    func getProducts(
        warehouseId: Int,
        page: Int,
        perPage: Int,
        searchFilter: String?,
        sort: SortType
    ) async -> DataResponse<(PaginatedResult, [Product])>
    
    func getProduct(productId: Int) async -> DataResponse<Product>
    
    func postProduct(warehouseId: Int, product: Product) async -> DataResponse<Product>
    
    func putProduct(product: Product) async -> DataResponse<Product>
    
    func deleteProduct(productId: Int) async -> DataResponse<Void>
    
    func getPathForProduct(productId: Int) async -> DataResponse<ProductPath>
    
    func encryptId(id: Int) async -> DataResponse<String>
    
    func decryptId(encrypted: String) async -> DataResponse<Int>
    
    func getPhoto(productId: Int) async -> DataResponse<HTTPBody?>
    
    func postPhoto(productId: Int, photoData: HTTPBody) async -> DataResponse<Void>
    
    func deletePhoto(productId: Int) async -> DataResponse<Void>
}

