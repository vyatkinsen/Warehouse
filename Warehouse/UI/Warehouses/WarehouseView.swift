import SwiftUI

struct WarehouseView: View {
    
    let projectName: String
    
    @StateObject private var viewModel: WarehousesViewModel
    
    init(projectId: Int, projectName: String) {
        self.projectName = projectName
        _viewModel = .init(wrappedValue: .init(projectId: projectId))
    }
    
    var body: some View {
        BaseView(viewModel: viewModel) { warehouses in
            CardsGridView(items: warehouses.map { ($0.id, $0.name) }) { id, name in
                ProductsView(warehouseId: id, warehouseName: name)
            }
        }
        .navigationTitle(projectName)
    }
}
