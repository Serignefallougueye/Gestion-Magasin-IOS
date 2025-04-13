import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showRegister = false

    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                
                // Logo
                Image("logo") // Remplace "logo" par le nom de ton image dans Assets.xcassets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding(.top, 40)
                
                // Titre
                Text("Connexion")
                    .font(.system(size: 28, weight: .bold))
                
                Text("Connectez-vous à votre compte")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                // Champs de texte
                VStack(spacing: 16) {
                    TextField("Votre adresse email", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Votre mot de passe", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Bouton Connexion
                Button(action: login) {
                    Text("Se connecter")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()

                // Lien vers l'inscription
                Button(action: {
                    showRegister = true
                }) {
                    Text("Créer un nouveau compte")
                        .foregroundColor(.orange)
                        .font(.footnote)
                        .underline()
                }
                .padding(.bottom, 20)
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Erreur"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
    
    private func login() {
        if email.isEmpty || password.isEmpty {
            alertMessage = "Veuillez remplir tous les champs"
            showingAlert = true
            return
        }
        
        if authService.login(email: email, password: password) {
            // Connexion réussie, la navigation sera gérée par l'état d'authentification
        } else {
            alertMessage = "Email ou mot de passe incorrect"
            showingAlert = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthService(context: PersistenceController.preview.container.viewContext))
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                configuration.label
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
