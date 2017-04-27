//
//  Settings.swift
//  Enhance
//
//  Created by Jonathan Baker on 4/27/17.
//
//

import Foundation

struct Settings {
    static var hasShownApplicationOnboarding: Bool {
        get {
            return UserDefaults.standard.bool(forKey: .hasShownApplicationOnboarding)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: .hasShownApplicationOnboarding)
        }
    }
}

fileprivate struct UserDefaultsKey: RawRepresentable {
    var rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(_ value: String) {
        self.init(rawValue: value)
    }
}

extension UserDefaults {
    fileprivate func bool(forKey key: UserDefaultsKey) -> Bool {
        return bool(forKey: key.rawValue)
    }

    fileprivate func set(_ value: Bool, forKey key: UserDefaultsKey) {
        set(value, forKey: key.rawValue)
    }
}

extension UserDefaultsKey {
    fileprivate static var hasShownApplicationOnboarding: UserDefaultsKey {
        return UserDefaultsKey("enhance-has-shown-application-onboarding")
    }
}
