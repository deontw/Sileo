//
//  LanguageHelper.swift
//  Sileo
//
//  Created by Andromeda on 03/08/2021.
//  Copyright © 2021 Sileo Team. All rights reserved.
//

import Foundation

final public class LanguageHelper {
    
    static let shared = LanguageHelper()
    public let availableLanguages: [Language]
    public var bundle: Bundle?
    
    init() {
        var locales = Bundle.main.localizations
        locales.removeAll { $0 == "Base" }
        locales.sort { $0 < $1 }
        
        let currentLocale = NSLocale.current as NSLocale
        var temp = [Language]()
        for language in locales {
            let locale = NSLocale(localeIdentifier: language)
            let display = locale.displayName(forKey: .identifier, value: language)?.capitalized(with: locale as Locale) ?? language
            let localizedDisplay = currentLocale.displayName(forKey: .identifier, value: language)?.capitalized(with: currentLocale as Locale) ?? language
            temp.append(Language(displayName: display, localizedDisplay: localizedDisplay, key: language))
        }
        availableLanguages = temp
        
        var selectedLanguage: String
        if UserDefaults.standard.object(forKey: "UseSystemLanguage") == nil {
            UserDefaults.standard.setValue(true, forKey: "UseSystemLanguage")
            return
        } else if UserDefaults.standard.bool(forKey: "UseSystemLanguage") {
            return
        // swiftlint:disable:next identifier_name
        } else if let _selectedLanguage = UserDefaults.standard.string(forKey: "SelectedLanguage") {
            selectedLanguage = _selectedLanguage
        } else {
            selectedLanguage = "Base"
            UserDefaults.standard.setValue("Base", forKey: "SelectedLanguage")
        }
        
        if let path = Bundle.main.path(forResource: selectedLanguage, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            let isRtl = Locale.characterDirection(forLanguage: selectedLanguage) == .rightToLeft
            UIView.appearance().semanticContentAttribute = isRtl ? .forceRightToLeft : .forceLeftToRight
            self.bundle = bundle
            return
        }
        
        guard selectedLanguage != "Base" else { return }
        if let path = Bundle.main.path(forResource: "Base", ofType: "lproj"),
           let bundle = Bundle(path: path) {
            self.bundle = bundle
            return
        }
    }
    
}

enum LocalizedStringType {
    case general, error, categories
    
    /// The table name this string type can be found in.
    var tableName: String? {
        switch self {
        case .general: return nil
        case .error: return "Errors"
        case .categories: return "Categories"
        }
    }
}

extension String {
    /// Creates a localized string from the provided key.
    init(localizationKey: String, type: LocalizedStringType = .general) {
        // swiftlint:disable nslocalizedstring_key
        if let bundle = LanguageHelper.shared.bundle {
            self = NSLocalizedString(localizationKey, tableName: type.tableName, bundle: bundle, comment: "")
        } else {
            self = NSLocalizedString(localizationKey, tableName: type.tableName, comment: "")
        }
    }
}
