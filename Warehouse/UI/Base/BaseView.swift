import SwiftUI

struct BaseView<Item, Content>: View where Content : View {
    
    @ObservedObject var viewModel: BaseViewModel<Item>
    
    @ViewBuilder let content: (Item) -> Content
    
    @EnvironmentObject private var domain: Domain
    
    @State private var showingAlert = false

    var body: some View {
        Group {
            if viewModel.loading {
                ProgressView()
            } else if let connectionError = viewModel.connectionError {
                Text("Ошибка подключения к серверу")
                    .font(.title2)
                    .multilineTextAlignment(.leading)
                    .padding(10)
                Text(connectionError)
                    .foregroundStyle(.red)
                    .padding(10)
            } else if let serverError = viewModel.serverError {
                Text("Ошибка при выполнении запроса")
                    .multilineTextAlignment(.leading)
                    .font(.title2)
                    .padding(10)
                Text(serverError)
                    .foregroundStyle(.red)
                    .padding(10)
                    .onAppear {
                        if serverError == "Адрес сервера не установлен" {
                            showingAlert = true
                        }
                    }
            } else if let item = viewModel.item {
                content(item)
            } else {
                Rectangle()
                    .hidden()
            }
        }
        .onAppear {
            viewModel.onAppear(domain: domain)
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Ошибка"),
                message: Text("Адрес сервера не установлен. Перейдите в настройки для его установки."),
                primaryButton: .default(Text("Настройки"), action: {
                    viewModel.openSettings()
                }),
                secondaryButton: .destructive(Text("Закрыть"), action: {
                    viewModel.closeApp()
                })
            )
        }
    }
}
