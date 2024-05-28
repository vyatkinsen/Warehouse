import SwiftUI
import PhotosUI

struct ProductPhotoView: View {
    
    @StateObject private var viewModel: ProductPhotoViewModel
    
    @Binding private var showFullScreenCover: Bool
    
    @Binding private var cameraPhoto: UIImage?
    
    @State private var photoItem: PhotosPickerItem?
    
    init(productId: Int, showFullScreenCover: Binding<Bool>, cameraPhoto: Binding<UIImage?>) {
        _viewModel = .init(wrappedValue: .init(productId: productId))
        self._showFullScreenCover = showFullScreenCover
        self._cameraPhoto = cameraPhoto
    }
    
    var body: some View {
        BaseView(viewModel: viewModel) { photoData in
            if let photoData = photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Button(role: .destructive) {
                    viewModel.deletePhoto()
                } label: {
                    Label("Удалить фото", systemImage: "trash")
                        .foregroundColor(.red)
                }
            } else {
                Button {
                    showFullScreenCover = true
                } label: {
                    Label("Сделать снимок", systemImage: "camera")
                }
                PhotosPicker(selection: $photoItem, matching: .not(.videos)) {
                    Label("Выбрать из фото", systemImage: "photo.on.rectangle")
                }
            }
        }
        .onChange(of: photoItem) {
            viewModel.setNewPhoto(photoItem: photoItem)
        }
        .onChange(of: cameraPhoto) {
            viewModel.setNewPhoto(cameraPhoto: cameraPhoto)
        }
    }
}
