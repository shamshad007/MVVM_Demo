//
//  LoginModel.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import Foundation

struct LoginModel: Codable {
    let accessToken: String?
    let refreshToken: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

