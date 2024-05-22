import Foundation

@MainActor
final class ProductsViewModel: BaseViewModel<Void> {
    
    private let perPage = 40
    
    private let warehouseId: Int
    
    init(warehouseId: Int) {
        self.warehouseId = warehouseId
        
        super.init()
    }
    
    @Published private (set) var products: [Product] = []
    
    @Published private (set) var hasNext = true
    
    private var page = -1
    
    private var searchFilter: String? = nil
    
    private var sort: SortType = .byNameAscending
    
    func loadNextPage(domain: Domain) {
        guard hasNext else { return }
        
        load(
            page: page + 1,
            searchFilter: searchFilter,
            sort: sort,
            domain: domain
        ) {
            self.products.append(contentsOf: $0)
        }
    }
    
    func loadNewParams(
        searchFilter: String? = nil,
        sort: SortType,
        domain: Domain
    ) {
        
        self.searchFilter = searchFilter
        self.sort = sort
        
        load(
            page: 0,
            searchFilter: searchFilter,
            sort: sort,
            domain: domain
        ) {
            self.products = $0
        }
    }
    
    private func load(
        page: Int,
        searchFilter: String?,
        sort: SortType,
        domain: Domain,
        onData: @escaping ([Product]) -> Void
    ) {
        makeRequest { [self] in
            await domain.getProducts(
                warehouseId: warehouseId,
                page: page,
                perPage: perPage,
                searchFilter: searchFilter,
                sort: sort,
                subject: $0
            )
        } onData: { [self] in
            hasNext = $0.0.has_next
            self.page = page
            onData($0.1)
        }
    }
    
    func resetProducts() {
        page = -1
        products = []
    }
}
