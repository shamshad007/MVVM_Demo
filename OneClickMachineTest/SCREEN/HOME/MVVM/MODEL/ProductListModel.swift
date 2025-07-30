//
//  ProductListModel.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import Foundation

struct ProductListModel: Codable {
    var id: Int?
    var title: String?
    var price: Int?
    var description: String?
    var images: [String]?
}
