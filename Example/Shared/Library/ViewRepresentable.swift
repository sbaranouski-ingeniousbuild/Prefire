#if DEBUG
import SwiftUI
import UIKit

@available(iOS 13.0, *)
public struct ViewRepresentable: UIViewRepresentable {

    @Environment(\.sizeCategory)
    var sizeCategory
    @Environment(\.dynamicTypeSize)
    var dynamicTypeSize

    let view: UIView
    
    public init(view: UIView) {
        self.view = view
    }
    
    public func makeUIView(context: Context) -> UIView {
        view
    }
    
    public func updateUIView(_ view: UIView, context: Context) {
        print(#function, sizeCategory, dynamicTypeSize)
    }
}
#endif
