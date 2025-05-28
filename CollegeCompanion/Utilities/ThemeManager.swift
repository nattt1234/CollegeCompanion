import SwiftUI

/// App theme and styling management
enum AppTheme {
    // MARK: - Colors
    enum Colors {
        // Primary app colors
        static let primary = Color.purple
        static let secondary = Color.blue
        static let accent = Color.pink
        
        // Module-specific colors
        static let productivity = Color.orange
        static let classes = Color.blue
        static let finance = Color.green
        static let wellness = Color.red
        static let organizer = Color.purple
        
        // UI Element colors
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let groupedBackground = Color(UIColor.systemGroupedBackground)
        
        // Text colors
        static let primaryText = Color(UIColor.label)
        static let secondaryText = Color(UIColor.secondaryLabel)
        static let tertiaryText = Color(UIColor.tertiaryLabel)
    }
    
    // MARK: - Dimensions
    enum Dimensions {
        // Common spacing
        static let spacing4: CGFloat = 4
        static let spacing8: CGFloat = 8
        static let spacing12: CGFloat = 12
        static let spacing16: CGFloat = 16
        static let spacing24: CGFloat = 24
        static let spacing32: CGFloat = 32
        
        // Radius values
        static let radiusSmall: CGFloat = 8
        static let radiusMedium: CGFloat = 12
        static let radiusLarge: CGFloat = 16
        
        // Widget sizes
        static let widgetHeight: CGFloat = 150
    }
    
    // MARK: - Text Styles
    enum TextStyle {
        static let title = Font.title.weight(.bold)
        static let headline = Font.headline
        static let subheadline = Font.subheadline
        static let body = Font.body
        static let caption = Font.caption
    }
}

// MARK: - Custom Shadow Type
struct CustomShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

extension AppTheme {
    // MARK: - Shadow Styles
    enum ShadowStyle {
        static let small = CustomShadow(
            color: .black.opacity(0.05),
            radius: 3,
            x: 0,
            y: 1
        )
        
        static let medium = CustomShadow(
            color: .black.opacity(0.1),
            radius: 5,
            x: 0,
            y: 2
        )
        
        static let large = CustomShadow(
            color: .black.opacity(0.15),
            radius: 10,
            x: 0,
            y: 4
        )
    }
}

// MARK: - CardStyle ViewModifier
struct CustomCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.Dimensions.spacing16)
            .background(AppTheme.Colors.background)
            .cornerRadius(AppTheme.Dimensions.radiusMedium)
            .shadow(
                color: AppTheme.ShadowStyle.small.color,
                radius: AppTheme.ShadowStyle.small.radius,
                x: AppTheme.ShadowStyle.small.x,
                y: AppTheme.ShadowStyle.small.y
            )
    }
}

// View extension for easy access to modifiers
extension View {
    func customCardStyle() -> some View {
        self.modifier(CustomCardModifier())
    }
}


