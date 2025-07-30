//
//  Error.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import Foundation

//MARK:- BN Error Handling Model
protocol ErrorProtocol: LocalizedError {
    var title: String? { get }
    var code: Int { get }
}

struct ApiError: Error, ErrorProtocol {
    var title: String?
    var code: Int
    var errorDescription: String? { self._description }
    var failureReason: String? { self._description }

    private var _description: String

    init(title: String?, description: String, code: Int) {
        self.title = title ?? "Error"
        self._description = description
        self.code = code
    }
}
