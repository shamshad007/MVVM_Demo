//
//  ProductViewModel.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import Foundation
import Combine

final class ProductViewModel: ObservableObject {
    
    // MARK: - Variables and Constants
    var cancellables = Set<AnyCancellable>()
    var authentication_error = PassthroughSubject<ApiError, Never>()
    @Published var productResponse: [ProductListModel]?
    
    // MARK: -  Fetch Product List Details
    func fetchProductListDetails(offset: String?, limit: String?, priceMin: String? = nil, priceMax: String? = nil, categoryId: String? = nil) {
        let webserviceURL = AppURL.product
            .appending("offset", value: offset)
            .appending("limit", value: limit)
            .appending("price_min", value: priceMin)
            .appending("price_max", value: priceMax)
            .appending("categoryId", value: categoryId)
        
        NetworkManager.shared.getData(endpoint: webserviceURL, apiMethod: Endpoint.GET, parameters: nil, type: [ProductListModel].self)
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .sink { completion in
                switch completion {
                case .finished:
                    print("sucessfully fetch product details data")
                case .failure(let err):
                    print("Product details Screen Error", err.localizedDescription)
                    self.authentication_error.send(ApiError(title: "Error", description: err.localizedDescription, code: err.code))
                }
            }
        receiveValue: { [weak self] responseData in
            self?.productResponse = responseData
        }
        .store(in: &self.cancellables)
    }
}


