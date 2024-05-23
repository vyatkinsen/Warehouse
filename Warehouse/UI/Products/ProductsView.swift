import SwiftUI

struct ProductsView: View {
    
    private let warehouseId: Int
    
    private let warehouseName: String
    
    private let sortNames: [(SortType, String)] = [
        (.byNameAscending, "По имени, а..я"),
        (.byNameDescending, "По имени, я..а"),
        (.byCountAscending, "По увеличению кол-ва"),
        (.byCountDescending, "По уменьшению кол-ва")
    ]
    
    @EnvironmentObject private var domain: Domain
    
    @StateObject private var viewModel: ProductsViewModel
    
    @State private var searchText: String = ""
    
    @State private var sort: SortType = .byNameAscending
    
    @State private var selectedProduct: Product? = nil
    
    @State private var addNewProduct: Bool = false
    
    init(warehouseId: Int, warehouseName: String) {
        self.warehouseId = warehouseId
        self.warehouseName = warehouseName
        
        self._viewModel = StateObject(wrappedValue: ProductsViewModel(warehouseId: warehouseId))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.products, id: \.id) { product in
                HStack {
                    Text(product.name)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedProduct = product
                }
            }
            if viewModel.hasNext {
                lastRowView
            }
        }
        .navigationTitle(warehouseName)
        .searchable(text: $searchText)
        .accessibilityIdentifier("productSearchField")
        .toolbar {
            Button {
                addNewProduct.toggle()
            } label: {
                Image(systemName: "plus")
            }
            .accessibilityIdentifier("addNewProductButton")
            Menu {
                Picker("Сортировка", selection: $sort) {
                    ForEach(sortNames, id: \.0) { item in
                        Text(item.1).tag(item.0)
                    }
                }
            } label: {
                Label("Сортировка", systemImage: "arrow.up.arrow.down")
            }
        }
        .sheet(item: $selectedProduct) { product in
            NavigationStack {
                ProductView(product: product) { isChanged in
                    selectedProduct = nil
                    onSheetResult(isChanged)
                }
            }
        }
        .sheet(isPresented: $addNewProduct) {
            NavigationStack {
                ProductView(warehouseId: warehouseId) { isChanged in
                    addNewProduct.toggle()
                    onSheetResult(isChanged)
                }
            }
        }
        .onChange(of: searchText, loadNewParams)
        .onChange(of: sort, loadNewParams)
    }
    
    var lastRowView: some View {
        ZStack(alignment: .center) {
            if viewModel.loading {
                ProgressView()
            } else if let serverError = viewModel.serverError {
                Text("Ошибка сервера \(serverError)")
            } else if let connectionError = viewModel.connectionError {
                Text("Ошибка подключения \(connectionError)")
            }
        }
        .frame(height: 50)
        .onAppear {
            viewModel.loadNextPage(domain: domain)
        }
    }
    
    private func loadNewParams() {
        viewModel.loadNewParams(
            searchFilter: searchText,
            sort: sort,
            domain: domain
        )
    }
    
    private func onSheetResult(_ isChange: Bool) {
        if isChange {
            viewModel.resetProducts()
        }
    }
}
