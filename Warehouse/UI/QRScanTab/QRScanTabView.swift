import SwiftUI
import CodeScanner
import AVFoundation

struct QRScanTabView: View {
    
    @State private var presentedProducts: [String] = []

    var body: some View {
        NavigationStack(path: $presentedProducts) {
            if let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                CodeScannerView(codeTypes: [.qr], videoCaptureDevice: backCamera) {
                    switch $0 {
                    case .success(let encrypted):
                        presentedProducts.append(encrypted.string)
                    case .failure(_):
                        print("fail")
                    }
                }
                .navigationDestination(for: String.self) { encrypted in
                    QRScanResView(encrypted: encrypted) {
                        presentedProducts = []
                    }
                }
            } else {
                Text("Back camera not available")
                    .foregroundColor(.red)
            }
        }
    }
}
