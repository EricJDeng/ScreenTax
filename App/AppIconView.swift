import SwiftUI

struct AppIconView: View {
    let app: MockApp
    var size: CGFloat = 54

    var body: some View {
        Group {
            if UIImage(named: app.assetName) != nil {
                Image(app.assetName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(size * 0.14)
                    .frame(width: size, height: size)
                    .background(Color.white)
            } else {
                Image(systemName: app.symbol)
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: size, height: size)
                    .background(app.tint.color.gradient)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: size * 0.235, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.235, style: .continuous)
                .strokeBorder(Color.black.opacity(0.08), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
    }
}
