#if DEBUG
import SwiftUI
import Prefire

public struct UIElementPreview<Content: View>: View {
    
    private let dynamicTypeSizes: [ContentSizeCategory] = [.extraSmall, .large, .extraExtraExtraLarge]
    
    /// Filter out "base" to prevent a duplicate preview.
    private let localizations = Bundle.main.localizations.map(Locale.init).filter { $0.identifier != "base" }
    
    private let viewToPreview: () -> Content
    
    public init(@ViewBuilder viewToPreview: @escaping () -> Content) {
        self.viewToPreview = viewToPreview
    }
    
    public var body: some View {
        Group {
            ForEach(localizations, id: \.identifier) { locale in
                self.viewToPreview()
                    .previewLayout(PreviewLayout.sizeThatFits)
                    .environment(\.locale, locale)
                    .previewDisplayName(Locale.current.localizedString(forIdentifier: locale.identifier))
                    .snapshot(delay: 1.0, precision: 0.8)
            }
            
            self.viewToPreview()
                .previewLayout(PreviewLayout.sizeThatFits)
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
                .snapshot(delay: 1.0, precision: 0.8)

            ForEach(dynamicTypeSizes, id: \.self) { sizeCategory in
                self.viewToPreview()
                    .previewLayout(PreviewLayout.sizeThatFits)
                    .environment(\.sizeCategory, sizeCategory)
                    .previewDisplayName("\(sizeCategory)")
                    .snapshot(delay: 1.0, precision: 0.8)
            }
        }
    }
}

#endif
