import XCTest
import Combine
@testable import Warehouse

final class DomainTests: XCTestCase {
    
    private var domain: Domain!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        domain = Domain()
    }
    
    override func tearDownWithError() throws {
        domain = nil
        
        try super.tearDownWithError()
    }
    
    func testAuth() async {
        await makeRequest { domain, subject in
            await domain.getAuth(login: "test", password: "123", subject: subject)
        } onData: { data in
            XCTAssertFalse(self.domain.needAuth.wrappedValue)
        }
    }
    
    func testProjects() async {
        await makeRequest { domain, subject in
            await domain.getProjects(subject: subject)
        } onData: { data in
            XCTAssertTrue(!data.isEmpty, "Проекты отсутствуют")
        }
    }
    
    func testWarehouses() async {
        await makeRequest { domain, subject in
            await domain.getWarehouses(projectId: 0, subject: subject)
        } onData: { data in
            XCTAssertTrue(!data.isEmpty, "Склады отсутствуют")
        }
    }
    
    func testProducts() async {
        let count = 20
        
        await makeRequest { domain, subject in
            await domain.getProducts(
                warehouseId: 0,
                page: 0,
                perPage: count,
                searchFilter: nil,
                sort: .byNameAscending,
                subject: subject
            )
        } onData: { (pag, products) in
            XCTAssertGreaterThanOrEqual(pag.total, count, "Кол-во в PaginatedResult меньше указанного")
            XCTAssertEqual(products.count, count, "Кол-во в [Product] не совпадает")
        }
    }
    
    func testProduct() async {
        let id = 1000000
        
        await makeRequest { domain, subject in
            await domain.getProduct(productId: id, subject: subject)
        } onData: { data in
            XCTAssertEqual(data.id, id, "ID не совпадают")
        }
    }
    
    func testPostProduct() async {
        let warehouseId = 0
        let product = Product(
            name: "Test",
            quantity: 1
        )
        
        await makeRequest { domain, subject in
            await domain.postProduct(warehouseId: warehouseId, product: product, subject: subject)
        } onData: { data in
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
        
        await makeRequest { domain, subject in
            await domain.putProduct(product: product, subject: subject)
        } onData: { data in
            XCTAssertEqual(data.id, product.id, "ID не совпадают")
            XCTAssertEqual(data.name, product.name, "Имя продукта не совпадает")
            XCTAssertEqual(data.quantity, product.quantity, "Кол-во продукта не совпадает")
        }
    }
    
    func testPathForProduct() async {
        let id = 1000000
        let projectName = "Проект 0"
        let warehouseName = "Большой"
        
        await makeRequest { domain, subject in
            await domain.getPathForProduct(productId: id, subject: subject)
        } onData: { data in
            XCTAssertEqual(data.projectName, projectName, "Имя проекта не совпадает")
            XCTAssertEqual(data.warehouseName, warehouseName, "Имя склада не совпадает")
        }
    }
    
    func testEncryptionDecryption() async {
        let id = 1000784
        
        await makeRequest { domain, subject in
            await domain.encryptId(id: id, subject: subject)
        } onData: { data in
            XCTAssertTrue(!data.isEmpty, "Строка пуста")
            XCTAssertNotEqual(data, "\(id)", "ID не зашифрован")
            
            Task {
                await self.makeRequest { domain, subject in
                    await domain.decryptId(encrypted: data, subject: subject)
                } onData: { data in
                    XCTAssertEqual(data, id, "ID не совпадают")
                }
            }
        }
    }
    
    func testGetPhoto() async {
        let id = 1000000
        
        await makeRequest { domain, subject in
            await domain.getPhoto(productId: id, subject: subject)
        } onData: { data in
            XCTAssertNotNil(data, "Фото нет")
        }
    }
    
    func testPostAndDeletePhoto() async {
        let id = 9000999
        let imageData = UIImage(systemName: "checkmark.seal")?.pngData()
        
        XCTAssertNotNil(imageData)
        
        await makeRequest { domain, subject in
            await domain.postPhoto(productId: id, photoData: .init(imageData!), subject: subject)
        } onData: { data in
            Task {
                await self.makeRequest { domain, subject in
                    await domain.deletePhoto(productId: id, subject: subject)
                } onData: { data in
                    
                }
            }
        }
    }
    
    private func makeRequest<T>(
        load: @escaping (Domain, PassSubject<T>) async -> Void,
        onData: @escaping (T) -> Void
    ) async {
        
        let subject = PassthroughSubject<DomainResponseOutput<T>, DomainResponseError>()
        
        let detectionCancellable = subject
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: receiveCompletion(completion:),
                receiveValue: {
                    self.receiveValue(result: $0, onData: onData)
                }
            )
        
        await load(domain, subject)
        
        detectionCancellable.cancel()
    }
    
    private func receiveCompletion(completion: Subscribers.Completion<DomainResponseError>) {
        if case .failure(let failure) = completion {
            XCTFail()
        }
    }
    
    private func receiveValue<T>(result: DomainResponseOutput<T>, onData: @escaping (T) -> Void) {
        switch result {
        case .success(let data):
            onData(data)
        }
    }
}
