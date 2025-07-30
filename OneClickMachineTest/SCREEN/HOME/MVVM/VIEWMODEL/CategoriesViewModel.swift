//
//  CategoriesViewModel.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import Foundation
import Combine

final class CategoriesViewModel: ObservableObject {
    
    // MARK: - Variables and Constants
    var cancellables = Set<AnyCancellable>()
    var authentication_error = PassthroughSubject<ApiError, Never>()
    @Published var categoriesResponse: [CategoriesModel]?
    
    // MARK: -  Fetch Categories Details
    func fetchCategoriesDetails() {
        let webserviceURL = AppURL.categories
        
        NetworkManager.shared.getData(endpoint: webserviceURL, apiMethod: Endpoint.GET, parameters: nil, type: [CategoriesModel].self)
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .sink { completion in
                switch completion {
                case .finished:
                    print("sucessfully fetch categories details data")
                case .failure(let err):
                    print("Categories details Screen Error", err.localizedDescription)
                    self.authentication_error.send(ApiError(title: "Error", description: err.localizedDescription, code: err.code))
                }
            }
        receiveValue: { [weak self] responseData in
            self?.categoriesResponse = responseData
        }
        .store(in: &self.cancellables)
    }
}

