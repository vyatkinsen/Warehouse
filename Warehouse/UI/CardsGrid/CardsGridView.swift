import SwiftUI
import WaterfallGrid

struct CardsGridView<Destination>: View where Destination: View {
    
    let items: [(Int, String)]
    
    @ViewBuilder let destination: (Int, String) -> Destination
    
    var body: some View {
        ScrollView {
            WaterfallGrid(items, id: \.0) { item in
                NavigationCardView(id: item.0, text: item.1, destination: destination)
            }
            .gridStyle(
                columns: 2,
                spacing: 10
            )
            .padding(10)
        }
    }
}


#Preview {
    NavigationStack {
        CardsGridView(items: (0...10).map { ($0, "Item \($0)") }) { id, text in
            Text("\(id), \(text)")
        }
    }
}
