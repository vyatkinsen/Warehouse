import SwiftUI
import Combine

struct ProductView: View {
    
    private let onClose: (_ isChanged: Bool) -> Void
    
    @StateObject private var viewModel: ProductViewModel
    
    @State private var name: String = ""
    
    @State private var quantity: Int = 1
    
    @State private var description: String = ""
    
    @State private var canSave: Bool

    @State private var showAlert = false
    
    private let fromScanner: Bool
    
    @State private var showFullScreenCover: Bool = false
    
    @State private var cameraPhoto: UIImage? = nil
    
    init(warehouseId: Int, onClose: @escaping (_ isChanged: Bool) -> Void) {
        _viewModel = StateObject(wrappedValue: ProductViewModel(warehouseId: warehouseId))
        
        self.onClose = onClose
        
        canSave = false
        
        fromScanner = false
    }
    
    init(product: Product, onClose: @escaping (_ isChanged: Bool) -> Void) {
        _viewModel = StateObject(wrappedValue: ProductViewModel(product: product))
        
        self.onClose = onClose
        
        canSave = true
        
        fromScanner = false
    }
    
    init(productId: Int, onClose: @escaping (_ isChanged: Bool) -> Void) {
        _viewModel = StateObject(wrappedValue: ProductViewModel(productId: productId))
        
        self.onClose = onClose
        
        canSave = false
        
        fromScanner = true
    }
    
    var body: some View {
        BaseView(viewModel: viewModel) { product in
            Form {
                if fromScanner, let id = product.id {
                    Section("Путь") {
                        ProductPathView(productId: id)
                    }
                }
                if let id = product.id {
                    Section("ID") {
                        Text(String(id))
                    }
                    Section("Фото") {
                        ProductPhotoView(productId: id, showFullScreenCover: $showFullScreenCover, cameraPhoto: $cameraPhoto)
                    }
                }
                Section("Описание") {
                    TextField("Наименование", text: $name)
                    
                    Stepper {
                        TextField("Количество", value: $quantity, format: .number)
                            .keyboardType(.decimalPad)
                    } onIncrement: {
                        quantity += 1
                    } onDecrement: {
                        quantity -= 1
                    }
                    
                    TextField("Описание", text: $description, axis: .vertical)
                    
                    if let id = product.id {
                        QRPrintButtonView(id: id)
                        Button(role: .destructive) {
                            showAlert = true
                        } label: {
                            Label("Удалить товар", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                        .alert("Вы уверены, что хотите удалить этот элемент?", isPresented: $showAlert) {
                            Button("Отмена", role: .cancel) { }
                            Button("Удалить", role: .destructive) {
                                viewModel.onDelete(id: id) {
                                    onClose(true)
                                }
                                showAlert = false
                            }
                        }
                    }

                    
                }
            }
            .onAppear {
                initProduct(product: product)
            }
        }
        .toolbar {
            if !fromScanner {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { onClose(false) }
                }
            }
            ToolbarItem {
                Button(viewModel.isNew ? "Добавить" : "Обновить") {
                    viewModel.onSave(
                        name: name,
                        quantity: quantity,
                        description: description
                    ) {
                        onClose(true)
                    }
                }
                .disabled(!canSave)
            }
        }
        .onChange(of: name) { old, new in
            if new.count > 200 {
                name = old
            }
            canSave = !name.isEmpty
        }
        .onChange(of: quantity) { old, new in
            if !(1...10000).contains(new) {
                quantity = old
            }
        }
        .onChange(of: description) { old, new in
            if new.count > 2000 {
                description = old
            }
        }
        .fullScreenCover(isPresented: $showFullScreenCover) {
            CameraView(selectedImage: $cameraPhoto)
        }
    }
    
    private func initProduct(product: Product) {
        name = product.name
        quantity = product.quantity
        description = product.description ?? ""
    }
}
