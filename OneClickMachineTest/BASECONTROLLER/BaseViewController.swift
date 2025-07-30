//
//  BaseViewController.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import UIKit
import MBProgressHUD

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: Show Alert And Hide
    func showAlertWithTextAtController(vc : UIViewController, title : String, message : String) {
        
        // the alert view
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        // Regular expression pattern for email validation
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    //MARK:- Shadow On Uiview
    func shadowOnUIView(name : UIView) {
        name.layer.shadowRadius = 8
        name.layer.shadowOffset = .zero
        name.layer.shadowOpacity = 0.2
        name.layer.shouldRasterize = true
        name.layer.rasterizationScale = UIScreen.main.scale
        name.layer.cornerRadius = 10.0
    }
    
    //MARK:- Loader
    func showLoader(text: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = text
    }
    
    func hideLoader() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}
