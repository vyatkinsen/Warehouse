import Foundation

@MainActor
final class ProductViewModel: BaseViewModel<Product> {
    
    @Published private (set) var isNew: Bool = false
    
    private let warehouseId: Int?
    
    private let productId: Int?
    
    init(warehouseId: Int) {
        self.warehouseId = warehouseId
        self.productId = nil
        
        isNew = true
        
        super.init(item: .init(name: "", quantity: 0))
    }
    
    init(product: Product) {
        self.warehouseId = nil
        self.productId = product.id
        
        super.init(item: product)
    }
    
    init(productId: Int) {
        self.warehouseId = nil
        self.productId = productId
        
        super.init()
    }
    
    override func onAppearLoader(domain: Domain, subject: PassSubject<Product>) async {
        guard let productId else {
            subject.send(completion: .finished)
            return
        }
        
        await domain.getProduct(productId: productId, subject: subject)
    }
    
    func onDelete(id: Int,
                  onSuccess: @escaping () -> Void
    ) {
        guard let domain = self.domain else { return }
        
        makeRequest {
            print(id)
            await domain.deleteProduct(productId: id, subject: $0)
        } onData: { _ in
            onSuccess()
        }
    }
    
    func onSave(
        name: String,
        quantity: Int,
        description: String?,
        onSuccess: @escaping () -> Void
    ) {
        
        let product = Product(
            id: self.item?.id,
            name: name,
            quantity: quantity,
            description: description
        )
        
        makeRequest {
            if let warehouseId = self.warehouseId {
                await self.domain!.postProduct(warehouseId: warehouseId, product: product, subject: $0)
            } else {
                await self.domain!.putProduct(product: product, subject: $0)
            }
        } onData: { _ in
            onSuccess()
        }
    }
}
