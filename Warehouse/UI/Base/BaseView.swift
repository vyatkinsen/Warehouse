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
                errorText("Ошибка подключения к серверу", connectionError)
            } else if let serverError = viewModel.serverError {
                errorText("Ошибка при выполнении запроса", serverError)                    
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
    
    @ViewBuilder
    func errorText(_ errorText: String, _ viewModelError: String) -> some View {
        Text(errorText)
            .font(.title2)
            .multilineTextAlignment(.leading)
            .padding(10)
        Text(viewModelError)
            .foregroundStyle(.red)
            .padding(10)
    }
}
