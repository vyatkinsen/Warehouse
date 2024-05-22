import SwiftUI

struct NavigationCardView<Destination>: View where Destination : View {
    
    let id: Int
    
    let text: String
    
    @ViewBuilder let destination: (Int, String) -> Destination
    
    var body: some View {
        NavigationLink {
            destination(id, text)
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(text)
                        .font(.title)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(.teal)
            .foregroundColor(.init("TextColor"))
            .cornerRadius(10)
        }
    }
}

#Preview {
    NavigationStack {
        NavigationCardView(id: 0, text: "Test") {
            Text("\($0), \($1)")
        }
    }
}
