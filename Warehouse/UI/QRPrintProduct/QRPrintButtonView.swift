import SwiftUI

struct QRPrintButtonView: View {
    
    @StateObject private var viewModel: QRPrintButtonViewModel
    
    init(id: Int) {
        _viewModel = .init(wrappedValue: QRPrintButtonViewModel(id: id))
    }
    
    var body: some View {
        BaseView(viewModel: viewModel) {
            Button {
                viewModel.onClick()
            } label: {
                Label("Напечатать QR-код", systemImage: "qrcode")
            }
        }
    }
}
