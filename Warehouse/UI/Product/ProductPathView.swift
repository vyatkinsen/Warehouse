import SwiftUI

struct ProductPathView: View {
    
    @StateObject private var viewModel: ProductPathViewModel
    
    init(productId: Int) {
        _viewModel = .init(wrappedValue: .init(productId: productId))
    }
    
    var body: some View {
        BaseView(viewModel: viewModel) { productPath in
            HStack {
                Text("\(productPath.projectName) → \(productPath.warehouseName)")
            }
        }
    }
}
