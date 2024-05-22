import XCTest
import OpenAPIRuntime
@testable import Warehouse

final class WarehouseClientAPITests: XCTestCase {
    
    private var client: WarehouseClientAPI!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        client = .init(url: URL(string: "http://127.0.0.1:8001")!)
    }

    override func tearDownWithError() throws {
        client = nil
        
        try super.tearDownWithError()
    }

    func testAuth() async {
        
        guard client.token == nil else { return }
        
        await makeRequest {
            await $0.getAuth(login: "test", password: "123")
        } onSuccess: { data in
            XCTAssertTrue(!data.isEmpty, "Токен отстуствует")
            client.token = data
        }
    }
    
    func testProjects() async {
        await makeAuthRequest {
            await $0.getProjects()
        } onSuccess: { data in
            XCTAssertTrue(!data.isEmpty, "Проекты отсутствуют")
        }
    }
    
    func testWarehouses() async {
        await makeAuthRequest {
            await $0.getWarehouses(projectId: 0)
        } onSuccess: { data in
            XCTAssertTrue(!data.isEmpty, "Склады отсутствуют")
        }
    }
    
    func testProducts() async {
        let count = 20
        
        await testAuth()
        
        let res = await client.getProducts(
            warehouseId: 0,
            page: 0,
            perPage: count,
            searchFilter: nil,
            sort: .byNameAscending
        )
        if case .success(let data) = res {
            XCTAssertGreaterThanOrEqual(data.0.total, count, "Кол-во в PaginatedResult меньше указанного")
            XCTAssertEqual(data.1.count, count, "Кол-во в [Product] не совпадает")
        } else {
            XCTFail()
        }
    }
    
    func testProduct() async {
        let id = 1000000
        
        await makeAuthRequest {
            await $0.getProduct(productId: id)
        } onSuccess: { data in
            XCTAssertEqual(data.id, id, "ID не совпадают")
        }
    }
    
    func testPostProduct() async {
        let warehouseId = 0
        let product = Product(
            name: "Test",
            quantity: 1
        )
        
        await makeAuthRequest {
            await $0.postProduct(warehouseId: warehouseId, product: product)
        } onSuccess: { data in
            XCTAssertNotNil(data.id, "ID не nil")
            XCTAssertEqual(data.name, product.name, "Имя продукта не совпадает")
            XCTAssertEqual(data.quantity, product.quantity, "Кол-во продукта не совпадает")
        }
    }
    
    func testPutProduct() async {
        let product = Product(
            id: 1000000,
            name: "TestPut",
            quantity: 789
        )
        
        await makeAuthRequest {
            await $0.putProduct(product: product)
        } onSuccess: { data in
            XCTAssertEqual(data.id, product.id, "ID не совпадают")
            XCTAssertEqual(data.name, product.name, "Имя продукта не совпадает")
            XCTAssertEqual(data.quantity, product.quantity, "Кол-во продукта не совпадает")
        }
    }
    
    func testPathForProduct() async {
        let id = 1000000
        let projectName = "Проект 0"
        let warehouseName = "Большой"
        
        await makeAuthRequest {
            await $0.getPathForProduct(productId: id)
        } onSuccess: { data in
            XCTAssertEqual(data.projectName, projectName, "Имя проекта не совпадает")
            XCTAssertEqual(data.warehouseName, warehouseName, "Имя склада не совпадает")
        }
    }
    
    func testEncryptionDecryption() async {
        let id = 1000784
        
        var encrypted: String? = nil
        
        await makeAuthRequest {
            await $0.encryptId(id: id)
        } onSuccess: { data in
            XCTAssertTrue(!data.isEmpty, "Строка пуста")
            XCTAssertNotEqual(data, "\(id)", "ID не зашифрован")
            
            encrypted = data
        }
        
        await makeAuthRequest {
            await $0.decryptId(encrypted: encrypted!)
        } onSuccess: { data in
            XCTAssertEqual(data, id, "ID не совпадают")
        }
    }
    
    func testGetPhoto() async {
        let id = 1000000
        
        await makeAuthRequest {
            await $0.getPhoto(productId: id)
        } onSuccess: { data in
            XCTAssertNil(data, "Фото нет")
        }
    }
    
    func testPostAndDeletePhoto() async {
        let id = 9000999
        let imageData = UIImage(systemName: "checkmark.seal")?.pngData()
        
        XCTAssertNotNil(imageData)
        
        await makeAuthRequest {
            await $0.postPhoto(productId: id, photoData: .init(imageData!))
        } onSuccess: { data in
            
        }
        
        await makeAuthRequest {
            await $0.deletePhoto(productId: id)
        } onSuccess: { data in
            
        }
    }
    
    private func makeAuthRequest<T>(request: (WarehouseClientAPI) async -> DataResponse<T>, onSuccess: (T) -> Void) async {
        await testAuth()
        await makeRequest(request: request, onSuccess: onSuccess)
    }
    
    private func makeRequest<T>(request: (WarehouseClientAPI) async -> DataResponse<T>, onSuccess: (T) -> Void) async {
        let res = await request(client)
        if case .success(let data) = res {
            onSuccess(data)
        } else {
            XCTFail()
        }
    }
}
