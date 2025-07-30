//
//  LoginViewController.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import UIKit
import Combine
import SwiftKeychainWrapper

class LoginViewController: BaseViewController {
    //MARK: - IBOutlet
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    //MARK: - View Model Object
    var loginViewModel: LoginViewModel = .init()
    var profileViewModel: ProfileViewModel = .init()
    var cancellable: Set<AnyCancellable> = .init()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setUpTextFields()
        self.subscribeToLoginDetails()
        self.subscribeToProfileDetails()
        self.checkApiError()
    }
    
    //MARK: - Functions
    private func setUpTextFields() {
        self.txtEmail.keyboardType = .emailAddress
        self.txtPassword.keyboardType = .namePhonePad
        self.txtPassword.isSecureTextEntry = true
        self.txtEmail.setRoundCorners(cornerRadius: 10.0, borderwidth: 1.0, bordercolor: .black)
        self.txtPassword.setRoundCorners(cornerRadius: 10.0, borderwidth: 1.0, bordercolor: .black)
        self.txtEmail.setLeftPaddingPoints(20)
        self.txtPassword.setLeftPaddingPoints(20)
        self.txtEmail.delegate = self
        self.txtPassword.delegate = self
    }
    
    //MARK: IBActions
    @IBAction func btnSignInActions(_ sender: UIButton) {
        if txtEmail.text?.isEmpty ?? true {
            self.showAlertWithTextAtController(vc: self, title: "Enter Mail ID", message: "")
        }
        else if !isValidEmail(txtEmail.text ?? "") {
            self.showAlertWithTextAtController(vc: self, title: "Enter Valid Email ID", message: "")
        }
        else if txtPassword.text?.isEmpty ?? true {
            self.showAlertWithTextAtController(vc: self, title: "Enter Password", message: "")
        } else {
            print("Login Successfully")
            self.showLoader(text: "Loading...")
            self.loginViewModel.fetchLoginDetails(email: self.txtEmail.text ?? "", password: self.txtPassword.text ?? "")
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension LoginViewController {
    // get login Details response
    func subscribeToLoginDetails() {
        self.loginViewModel.$loginResponse.sink { [weak self] responseData in
            guard self != nil else {return}
            if let response = responseData {
                debugPrint("Login details data: \(response)")
                
                // Save token
                KeychainWrapper.standard.set(response.accessToken ?? "", forKey: "access_token")
                
                self?.profileViewModel.fetchProfileDetails()
            }
        }
        .store(in: &self.cancellable)
    }
    
    // get profile Details response
    func subscribeToProfileDetails() {
        self.profileViewModel.$profileResponse.sink { [weak self] responseData in
            guard self != nil else {return}
            if let response = responseData {
                debugPrint("profile details data: \(response)")
                
                // Save Customer Details
                UserDefaultsManager.shared.setStringValue(response.name ?? "", forKey: UserDefaultsKey.name)
                UserDefaultsManager.shared.setStringValue(response.email ?? "", forKey: UserDefaultsKey.email)
                UserDefaultsManager.shared.setStringValue(response.avatar ?? "", forKey: UserDefaultsKey.avatar)
                
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
            self?.hideLoader()
        }
        .store(in: &self.cancellable)
    }
    
    // api error handling
    func checkApiError() {
        self.loginViewModel.authentication_error.sink { response in
            self.showAlertWithTextAtController(vc: self , title: response.errorDescription ?? "", message: "")
            self.hideLoader()
        }
        .store(in: &self.cancellable)
    }
}
