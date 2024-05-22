import Foundation

@MainActor
final class ProductPathViewModel: BaseViewModel<ProductPath> {
    
    private let productId: Int
    
    init(productId: Int) {
        self.productId = productId
        
        super.init()
    }
    
    override func onAppearLoader(domain: Domain, subject: PassSubject<ProductPath>) async {
        await domain.getPathForProduct(productId: productId, subject: subject)
    }
}
