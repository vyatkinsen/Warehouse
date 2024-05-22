import SwiftUI
import PhotosUI

@MainActor
final class ProductPhotoViewModel: BaseViewModel<Data?> {
    
    private let productId: Int
    
    init(productId: Int) {
        self.productId = productId
        
        super.init()
    }
    
    override func onAppearLoader(domain: Domain, subject: PassSubject<Data?>) async {
        await domain.getPhoto(productId: self.productId, subject: subject)
    }
    
    func setNewPhoto(photoItem: PhotosPickerItem?) {
        setNewPhoto {
            try? await photoItem?.loadTransferable(type: Data.self)
        }
    }
    
    func setNewPhoto(cameraPhoto: UIImage?) {
        setNewPhoto {
            cameraPhoto?.pngData()
        }
    }
    
    private func setNewPhoto(getPhotoData: @escaping () async -> Data?) {
        var photoData: Data? = nil
        makeRequest { subject in
            photoData = await getPhotoData()
            if let photoData = photoData {
                await self.domain!.postPhoto(productId: self.productId, photoData: photoData, subject: subject)
            } else {
                subject.send(completion: .finished)
            }
        } onData: {
            self.item = photoData
        }
    }
    
    func deletePhoto() {
        guard item != nil else { return }
        
        makeRequest {
            await self.domain!.deletePhoto(productId: self.productId, subject: $0)
        } onData: {
            self.item = nil
        }
    }
}
