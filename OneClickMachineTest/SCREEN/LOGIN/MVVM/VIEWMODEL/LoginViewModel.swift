//
//  LoginViewModel.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import Foundation
import Combine

final class LoginViewModel: ObservableObject {
    
    // MARK: - Variables and Constants
    var cancellables = Set<AnyCancellable>()
    var authentication_error = PassthroughSubject<ApiError, Never>()
    @Published var loginResponse: LoginModel?
    
    // MARK: -  Fetch Login Details
    func fetchLoginDetails(email: String, password: String) {
        let webserviceURL = AppURL.login
        let param = [
            "email": email,
            "password": password
        ]
        
        NetworkManager.shared.getData(endpoint: webserviceURL, apiMethod: Endpoint.POST, parameters: param, type: LoginModel.self)
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .sink { completion in
                switch completion {
                case .finished:
                    print("sucessfully fetch login details data")
                case .failure(let err):
                    print("Login details Screen Error", err.localizedDescription)
                    self.authentication_error.send(ApiError(title: "Error", description: err.localizedDescription, code: err.code))
                }
            }
        receiveValue: { [weak self] responseData in
            self?.loginResponse = responseData
        }
        .store(in: &self.cancellables)
    }
}
