import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("isDarkMode") var isDarkMode = false
    @AppStorage("useSystemTheme") var useSystemTheme = true
    @AppStorage("accentColor") var accentColorString = "blue"
    
    var accentColor: Color {
        get {
            switch accentColorString {
            case "blue": return .blue
            case "purple": return .purple
            case "green": return .green
            case "orange": return .orange
            default: return .blue
            }
        }
        set {
            switch newValue {
            case .blue: accentColorString = "blue"
            case .purple: accentColorString = "purple"
            case .green: accentColorString = "green"
            case .orange: accentColorString = "orange"
            default: accentColorString = "blue"
            }
        }
    }
    
    var colorScheme: ColorScheme? {
        if useSystemTheme {
            return nil
        } else {
            return isDarkMode ? .dark : .light
        }
    }
} 