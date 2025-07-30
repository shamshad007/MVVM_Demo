//
//  EndPoint.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import Foundation

//MARK: - End Points
enum Endpoint: String {
    case POST
    case GET
    case UPDATE
    case DELETE
    case PATCH
    var endpoint: String {
        switch self {
        case .POST:
            return "POST"
        case .GET:
            return "GET"
        case .UPDATE:
            return "UPDATE"
        case .DELETE:
            return "DELETE"
        case .PATCH:
            return "PATCH"
        }
    }
}
