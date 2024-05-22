import SwiftUI

struct QRScanResView: View {
    
    private let onClose: () -> Void
    
    @StateObject private var viewModel: QRScanResViewModel
    
    init(encrypted: String, onClose: @escaping () -> Void) {
        self.onClose = onClose
        
        _viewModel = .init(wrappedValue: .init(encrypted: encrypted))
    }
    
    var body: some View {
        BaseView(viewModel: viewModel) { productId in
            ProductView(productId: productId) { _ in
                onClose()
            }
        }
    }
}
