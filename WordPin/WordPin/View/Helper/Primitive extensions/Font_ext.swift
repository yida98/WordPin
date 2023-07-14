//
//  Font_ext.swift
//  WordPin
//
//  Created by Yida Zhang on 7/12/23.
//

import Foundation
import SwiftUI

extension Font {
    public static func gameFont(size: UIFont.TextStyle = .body) -> Font {
        Font.custom("PublicPixel-z84yD", size: UIFont.preferredFont(forTextStyle: size).pointSize)
    }
    
    public static func digitalFont(size: UIFont.TextStyle = .body) -> Font {
        Font.custom("DigitalNumbers-Regular", size: UIFont.preferredFont(forTextStyle: size).pointSize)
    }
    
    public static func secondaryFont(size: UIFont.TextStyle = .body) -> Font {
        Font.custom("VT323-Regular", size: UIFont.preferredFont(forTextStyle: size).pointSize)
    }
    
    public static func primary(size: UIFont.TextStyle = .body, emphasis: Emphasis = .regular) -> Font {
        var font = "IBMPlexSans-Regular"
        switch emphasis {
        case .semiBoldItalic: font = "IBMPlexSans-SemiBoldItalic"
        case .medium: font = "IBMPlexSans-Medium"
        case .semiBold: font = "IBMPlexSans-SemiBold"
        case .mediumItalic: font = "IBMPlexSans-MediumItalic"
        case .lightItalic: font = "IBMPlexSans-LightItalic"
        case .extraLight: font = "IBMPlexSans-ExtraLight"
        case .thin: font = "IBMPlexSans-Thin"
        case .thinItalic: font = "IBMPlexSans-ThinItalic"
        case .boldItalic: font = "IBMPlexSans-BoldItalic"
        case .light: font = "IBMPlexSans-Light"
        case .italic: font = "IBMPlexSans-Italic"
        case .bold: font = "IBMPlexSans-Bold"
        default: break
        }
        return Font.custom(font, size: UIFont.preferredFont(forTextStyle: size).pointSize)
    }
    
    public enum Emphasis {
        case semiBoldItalic, medium, semiBold, mediumItalic, lightItalic, extraLight, thin, thinItalic, boldItalic, light, italic, regular, extraLightItalic, bold
    }
}
