//
//  URL.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import Foundation

extension URL {
    
    func appending(_ queryItem: String, value: Any?) -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }
        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
        // Create query item
        let queryItem = URLQueryItem(name: queryItem, value: value as? String)
        // Append the new query item in the existing query items array
        queryItems.append(queryItem)
        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems
        // Returns the url from new url components
        return urlComponents.url ?? URL(fileURLWithPath: "")
        /*
         Useage:
         var url = URL(string: "https://www.example.com")!
         let finalURL = url.appending("test", value: "123")
         .appending("test2", value: nil)
         
         */
    }
}
