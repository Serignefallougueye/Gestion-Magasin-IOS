import SwiftUI

struct SidebarView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Logo et titre
            HStack {
                Image(systemName: "cube.box.fill")
                    .font(.title)
                Text("Gestion Des\nProduits")
                    .font(.headline)
                    .multilineTextAlignment(.leading)
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Menu items
            VStack(spacing: 5) {
                MenuLink(icon: "chart.pie.fill", title: "Tableau de Bord", isActive: true)
                MenuLink(icon: "cube.fill", title: "Produits")
                MenuLink(icon: "list.clipboard.fill", title: "Inventaire")
                MenuLink(icon: "cart.fill", title: "Achats")
                MenuLink(icon: "building.2.fill", title: "Fournisseurs")
                MenuLink(icon: "arrow.triangle.2.circlepath", title: "Réapprovisionnement")
                MenuLink(icon: "mappin.circle.fill", title: "Emplacements")
                MenuLink(icon: "chart.bar.fill", title: "Rapports")
                MenuLink(icon: "person.2.fill", title: "Utilisateurs")
            }
            .padding(.vertical)
            
            Spacer()
            
            // Footer menu
            VStack(spacing: 5) {
                
                MenuLink(icon: "gearshape.fill", title: "Paramètres")
                MenuLink(icon: "rectangle.portrait.and.arrow.right.fill", title: "Déconnexion")
            }
            .padding(.vertical)
        }
        .frame(width: 200)
        .background(Color.black)
    }
}

struct MenuLink: View {
    let icon: String
    let title: String
    var isActive: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 20)
            Text(title)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(isActive ? Color.blue.opacity(0.2) : Color.clear)
        .foregroundColor(isActive ? .blue : .white)
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
} 
