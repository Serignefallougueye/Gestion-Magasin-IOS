import SwiftUI

struct SettingsView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) var systemColorScheme
    @State private var notificationsEnabled = true
    @State private var stockAlertNotifications = true
    @State private var orderStatusNotifications = true
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("APPARENCE")) {
                    Toggle("Utiliser le thème système", isOn: $themeManager.useSystemTheme)
                    
                    if !themeManager.useSystemTheme {
                        Toggle("Mode sombre", isOn: $themeManager.isDarkMode)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Couleur d'accent")
                        HStack(spacing: 12) {
                            ColorButton(color: .blue, selectedColor: themeManager.accentColor) {
                                themeManager.accentColor = .blue
                            }
                            ColorButton(color: .purple, selectedColor: themeManager.accentColor) {
                                themeManager.accentColor = .purple
                            }
                            ColorButton(color: .green, selectedColor: themeManager.accentColor) {
                                themeManager.accentColor = .green
                            }
                            ColorButton(color: .orange, selectedColor: themeManager.accentColor) {
                                themeManager.accentColor = .orange
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("NOTIFICATIONS")) {
                    Toggle("Activer les notifications", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        Toggle("Alertes de stock", isOn: $stockAlertNotifications)
                            .tint(themeManager.accentColor)
                        
                        Toggle("Statut des commandes", isOn: $orderStatusNotifications)
                            .tint(themeManager.accentColor)
                    }
                }
                
                Section(header: Text("À PROPOS")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Paramètres")
        }
    }
}

struct ColorButton: View {
    let color: Color
    let selectedColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 30, height: 30)
                .overlay(
                    Circle()
                        .stroke(color == selectedColor ? Color.primary : Color(.clear), lineWidth: 2)
                )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 