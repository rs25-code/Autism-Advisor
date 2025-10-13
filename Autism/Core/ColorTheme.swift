//
//  ColorTheme.swift
//  Autism
//
//  Created by Rhea Sreedhar on 9/10/25.
//

import SwiftUI

// MARK: - Color Theme System
struct ColorTheme {
    
    // MARK: - Primary Brand Colors
    static let primary = Color.blue           // Changed from orange to blue for better accessibility
    static let primaryDark = Color.blue.opacity(0.8)
    static let primaryLight = Color.blue.opacity(0.1)
    
    // MARK: - Secondary Brand Colors
    static let secondary = Color.purple       // Complementary to blue
    static let secondaryDark = Color.purple.opacity(0.8)
    static let secondaryLight = Color.purple.opacity(0.1)
    
    // MARK: - Functional Status Colors (Following Apple HIG)
    static let success = Color.green          // For "onTrack" status
    static let warning = Color.orange         // For "needsAttention" status
    static let error = Color.red              // For "behind" status
    static let info = Color.blue.opacity(0.8) // For informational messages
    
    // MARK: - Text Colors
    struct Text {
        static let primary = Color.primary          // System primary text
        static let secondary = Color.secondary      // System secondary text
        static let onPrimary = Color.white         // Text on primary colored backgrounds
        static let onSecondary = Color.white       // Text on secondary colored backgrounds
        static let onSuccess = Color.white         // Text on success backgrounds
        static let onWarning = Color.black         // Changed: Better contrast on orange
        static let onError = Color.white           // Text on error backgrounds
        static let accent = ColorTheme.primary     // Accent text color
    }
    
    // MARK: - Background Colors
    struct Background {
        static let primary = Color(.systemBackground)
        static let secondary = Color(.secondarySystemBackground)
        static let tertiary = Color(.tertiarySystemBackground)
        static let card = Color(.systemGray6).opacity(0.3)
        static let overlay = Color.black.opacity(0.4)
    }
    
    // MARK: - Border Colors
    struct Border {
        static let primary = ColorTheme.primary.opacity(0.3)
        static let secondary = ColorTheme.secondary.opacity(0.3)
        static let light = Color(.systemGray4)
        static let medium = Color(.systemGray3)
    }
    
    // MARK: - Role-Based Colors (Updated for clarity)
    struct Role {
        static let parent = ColorTheme.primary      // Blue for parents
        static let teacher = ColorTheme.secondary   // Purple for teachers
        static let counselor = Color.green          // Green for counselors
    }
    
    // MARK: - Chat Colors
    struct Chat {
        static let userBubble = ColorTheme.primary
        static let userText = ColorTheme.Text.onPrimary
        static let aiBubble = Color(.systemGray5)
        static let aiText = ColorTheme.Text.primary
        static let systemBubble = ColorTheme.info.opacity(0.1)
        static let systemText = ColorTheme.info
        static let errorBubble = ColorTheme.error.opacity(0.1)
        static let errorText = ColorTheme.error
        static let thinkingBubble = ColorTheme.warning.opacity(0.1)
        static let thinkingText = ColorTheme.warning
    }
    
    // MARK: - Chart Colors
    struct Chart {
        static let primary = ColorTheme.primary
        static let secondary = ColorTheme.secondary
        static let accent = Color.cyan
        static let gradient = [ColorTheme.primary.opacity(0.7), ColorTheme.primary, ColorTheme.primary.opacity(0.9)]
        static let gridLines = Color(.systemGray4)
    }
    
    // MARK: - Progress Colors
    struct Progress {
        static let track = Color(.systemGray4)
        static let fill = ColorTheme.primary
        static let high = ColorTheme.success      // 80%+ progress
        static let medium = ColorTheme.warning    // 40-79% progress
        static let low = ColorTheme.error         // <40% progress
    }
    
    // MARK: - Upload Screen Colors
    struct Upload {
        static let dropZoneBorder = ColorTheme.primary
        static let dropZoneBackground = ColorTheme.primaryLight
        static let icon = ColorTheme.primary
        static let actionText = ColorTheme.primary
    }
}

// MARK: - Color Theme Extensions
extension Color {
    // Convenience accessors for theme colors
    static let themePrimary = ColorTheme.primary
    static let themeSecondary = ColorTheme.secondary
    static let themeSuccess = ColorTheme.success
    static let themeWarning = ColorTheme.warning
    static let themeError = ColorTheme.error
}

// MARK: - UIColor Extensions (for global app appearance)
extension UIColor {
    static let themePrimary = UIColor(ColorTheme.primary)
    static let themeSecondary = UIColor(ColorTheme.secondary)
}

// MARK: - Dark Mode Support
extension ColorTheme {
    // Colors automatically adapt to dark mode through SwiftUI's Color system
    // No additional configuration needed as we're using system colors where appropriate
    
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        return Color(.init { traitCollection in
            return traitCollection.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}
