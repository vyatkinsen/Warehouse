import Foundation
import UIKit

@MainActor
final class QRPrintButtonViewModel: BaseViewModel<Void> {
    
    private let id: Int
    
    init(id: Int) {
        self.id = id
        
        super.init(item: ())
    }
    
    override func onAppearLoader(domain: Domain, subject: PassSubject<Void>) async {
        subject.send(completion: .finished)
    }
    
    func onClick() {
        makeRequest {
            await self.domain!.encryptId(id: self.id, subject: $0)
        } onData: {
            self.print(encoded: $0)
        }
    }
    
    private func print(encoded: String) {
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfo.OutputType.general
        printInfo.jobName = "Warehouse QR"
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        
        printController.printingItem = generateQRCode(from: encoded)
        
        printController.present(animated: true)
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 20, y: 20)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
}
