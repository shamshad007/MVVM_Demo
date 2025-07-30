//
//  ProfileViewModel.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import Foundation
import Combine

final class ProfileViewModel: ObservableObject {
    
    // MARK: - Variables and Constants
    var cancellables = Set<AnyCancellable>()
    var authentication_error = PassthroughSubject<ApiError, Never>()
    @Published var profileResponse: ProfileModel?
    
    // MARK: -  Fetch Profile Details
    func fetchProfileDetails() {
        let webserviceURL = AppURL.profile
        
        NetworkManager.shared.getData(endpoint: webserviceURL, apiMethod: Endpoint.GET, parameters: nil, type: ProfileModel.self)
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .sink { completion in
                switch completion {
                case .finished:
                    print("sucessfully fetch profile details data")
                case .failure(let err):
                    print("Profile details Screen Error", err.localizedDescription)
                    self.authentication_error.send(ApiError(title: "Error", description: err.localizedDescription, code: err.code))
                }
            }
        receiveValue: { [weak self] responseData in
            self?.profileResponse = responseData
        }
        .store(in: &self.cancellables)
    }
}
