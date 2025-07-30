//
//  UserDefaultManager.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import Foundation

extension UserDefaultsKey: Codable {
    public init(from decoder: Decoder) throws {
        self = try UserDefaultsKey(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

// MARK: - Userdefaults Get - Set Methods

final class UserDefaultsManager: NSObject {
    static let shared = UserDefaultsManager()
    private let userDefaults = UserDefaults.standard
    func setStringValue(_ value: String, forKey: UserDefaultsKey) {
        self.userDefaults.set(value, forKey: forKey.rawValue)
    }
    
    func getStringValue(forKey: UserDefaultsKey) -> String {
        if let value = self.userDefaults.value(forKey: forKey.rawValue) as? String {
            return value
        } else {
            return ""
        }
    }
    
    func removeValue(forKey: UserDefaultsKey) {
        self.userDefaults.removeObject(forKey: forKey.rawValue)
    }
}

enum UserDefaultsKey: String {
    case acccessToken = "access_token"
    case name
    case email
    case avatar
    case unknown
}
