import SwiftUI

struct AuthUI: View {
    
    @EnvironmentObject private var domain: Domain
    
    @StateObject private var viewModel: AuthViewModel = AuthViewModel()
    
    @State private var login: String = ""
    @State private var password: String = ""
    
    @FocusState private var loginFieldIsFocused: Bool
    @FocusState private var passwordFieldIsFocused: Bool
    
    var body: some View {
        VStack {
            if viewModel.loading {
                ProgressView()
                    .padding()
            }
            
            if let connectionError = viewModel.connectionError {
                Text("Ошибка подключения к серверу")
                    .font(.title2)
                    .multilineTextAlignment(.leading)
                    .padding(10)
                Text(connectionError)
                    .foregroundStyle(.red)
                    .padding(10)
            }
            
            if let serverError = viewModel.serverError {
                Text("Ошибка при выполнении запроса")
                    .multilineTextAlignment(.leading)
                    .font(.title2)
                    .padding(10)
                Text(serverError)
                    .foregroundStyle(.red)
                    .padding(10)
//                errorText("Ошибка при выполнении запроса (\(serverError))")
            }
            Text("Для авторизации в приложении введите логин и пароль")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(10)

            TextField("Логин", text: $login)
                .textContentType(.username)
                .focused($loginFieldIsFocused)
                .onSubmit {
                    loginFieldIsFocused = false
                    passwordFieldIsFocused = true
                }
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding(.leading, 10)
                .frame(height: 50)
                .background(Color.teal.opacity(0.2))
                .foregroundColor(.init("TextColor"))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.teal, lineWidth: 1)
                )

            SecureField("Пароль", text: $password)
                .textContentType(.password)
                .focused($passwordFieldIsFocused)
                .onSubmit {
                    viewModel.auth(login: login, password: password, domain: domain)
                }
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding(.leading, 10)
                .frame(height: 50)
                .background(Color.teal.opacity(0.2))
                .foregroundColor(.init("TextColor"))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.teal, lineWidth: 1)
                )
        }
        .onAppear {
            loginFieldIsFocused = true
        }
        .padding()
    }
    
    @ViewBuilder
    func errorText(_ errorText: String) -> some View {
        Text(errorText)
            .foregroundStyle(.red)
            .padding()
    }
}

#Preview {
    AuthUI()
}
