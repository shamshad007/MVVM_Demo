//
//  URLS.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import Foundation

struct AppURL {
    public static var BaseURL = "https://api.escuelajs.co/api/v1/"
    
    static var login: URL {
        return URL(string: BaseURL + "auth/login") ?? URL(fileURLWithPath: "")
    }
    
    static var profile: URL {
        return URL(string: BaseURL + "auth/profile") ?? URL(fileURLWithPath: "")
    }
    
    static var categories: URL {
        return URL(string: BaseURL + "categories") ?? URL(fileURLWithPath: "")
    }
    
    static var product: URL {
        return URL(string: BaseURL + "products") ?? URL(fileURLWithPath: "")
    }
}
