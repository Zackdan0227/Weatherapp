import SwiftUI
import SVGKit

struct SVGView: UIViewRepresentable {
    var name: String

    func makeUIView(context: Context) -> SVGKFastImageView {
        // Attempt to load the SVG file
        guard let svgImage = SVGKImage(named: name),
              let svgView = SVGKFastImageView(svgkImage: svgImage) else {
            // Fallback if the SVG file cannot be found or the SVGKFastImageView initialization fails
            let placeholderView = SVGKFastImageView(svgkImage: SVGKImage())
            placeholderView?.backgroundColor = .gray // Safely unwrap the placeholderView
            return placeholderView ?? SVGKFastImageView()
        }
        
        svgView.contentMode = .scaleAspectFit
        return svgView
    }

    func updateUIView(_ uiView: SVGKFastImageView, context: Context) {
        // Update the view if needed
    }
}

struct SVGView_Previews: PreviewProvider {
    static var previews: some View {
        SVGView(name: "partly-cloudy-day")
            .frame(width: 100, height: 100)
            .previewLayout(.sizeThatFits)
    }
}
