import UIKit

class NatureView: UIView {
    let imageView = UIImageView(image: .init(named: "nature"))

    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(imageView)
        imageView.frame = bounds
    }
}

#if DEBUG
import SwiftUI
import Prefire

internal class ProgramModuleViewPreview: PreviewProvider, PrefireProvider {
    static var previews: some View {
        UIElementPreview {
            ViewRepresentable(
                view: NatureView()
            )
            .frame(width: 512, height: 512)
            .previewLayout(.sizeThatFits)
        }
    }
}

#endif
