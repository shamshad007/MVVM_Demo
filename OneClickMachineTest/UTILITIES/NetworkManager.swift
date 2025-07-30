//
//  NetworkManager.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import Foundation
import Combine
import SwiftKeychainWrapper

enum ResultData<T> {
    case success(T)
    case failure(Error)
}

final class NetworkManager {
    static let shared: NetworkManager = .init()
    private init() {}
    var httpErrorCode = 0
    var cancellables = Set<AnyCancellable>()

    func getData<T: Decodable>(endpoint: URL, apiMethod: Endpoint, parameters: [String: Any]?, type: T.Type) -> Future<T, ApiError> {
        Future<T, ApiError> { [weak self] promise in
            guard let self = self else { return }
            var request = URLRequest(url: endpoint)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            switch apiMethod {
            case .POST:
                if parameters != nil {
                    if let parameter = parameters {
                        if !parameter.isEmpty {
                            request.httpBody = try? JSONSerialization.data(withJSONObject: parameter, options: [])
                        }
                    }
                }
                print("URL Request  = \(apiMethod.endpoint)")
                print("URL is \(endpoint) and param for POST:", parameters as Any)
            case .GET:
                if parameters != nil {
                    if let parameter = parameters {
                        if !parameter.isEmpty {
                            request.httpBody = try? JSONSerialization.data(withJSONObject: parameter, options: [])
                        }
                    }
                }
                print("URL Request =  \(apiMethod.endpoint)")
                print("URL is \(endpoint)")
            case .UPDATE:
                print("URL Request = \(apiMethod.endpoint)")
                print("URL is \(endpoint)")
            case .DELETE:
                print("URL Request = \(apiMethod.endpoint)")
                print("URL is \(endpoint) ")
            case .PATCH:
                if parameters != nil {
                    if let parameter = parameters {
                        if !parameter.isEmpty {
                            request.httpBody = try? JSONSerialization.data(withJSONObject: parameter, options: [])
                        }
                    }
                }
                print("URL Request = \(apiMethod.endpoint)")
                print("URL is \(endpoint) ")
            }
            request.httpMethod = apiMethod.endpoint
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            // Retrieve token
            if let token = KeychainWrapper.standard.string(forKey: "access_token") {
                print(token)
                let headers = [
                    "Authorization": "Bearer " + token,
                    "Content-Type": "application/json"
                ]
                print("check API call header", headers)
                request.allHTTPHeaderFields = headers
            }

            URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, 200 ... 299 ~= httpResponse.statusCode else {
                        var error_message = "Unknown"
                        do {
                            // make sure this JSON is in the format we expect
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                // try to read out a string array
                                if let error = json["message"] as? String {
                                    error_message = error
                                }
                            }
                        } catch let error as NSError {
                            print("Failed to loadfor url \(endpoint): \(error.localizedDescription)")
                        }
                        if let statusCode = response as? HTTPURLResponse {
                            self.httpErrorCode = statusCode.statusCode
                        }
                        throw (ApiError(title: "Error", description: error_message, code: self.httpErrorCode))
                    }
                    self.httpErrorCode = httpResponse.statusCode
                    let str = String(decoding: data, as: UTF8.self)
                    print("Check status code for url \(endpoint):", httpResponse.statusCode)
                    print("Response for url \(endpoint)::", str)
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        switch error {
                        case let decodingError as DecodingError:
                            promise(.failure(ApiError(title: "Error", description: decodingError.localizedDescription, code: self.httpErrorCode)))
                        case let apiError as ApiError:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(ApiError(title: "Error", description: error.localizedDescription, code: self.httpErrorCode)))
                        }
                    }
                }, receiveValue: {
                    promise(.success($0))
                })
                .store(in: &self.cancellables)
        }
    }

    private static func getData(url: URL,
                                completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    // MARK: - Public function
    /// downloadImage function will download the thumbnail images
    /// returns Result<Data> as completion handler
    static func downloadImage(url: URL,
                              completion: @escaping (ResultData<Data>) -> Void) {
        self.getData(url: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }
    }
}




