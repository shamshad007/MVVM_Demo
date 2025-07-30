//
//  LogoutVC.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import UIKit

class LogoutVC: BaseViewController {

    var dismissPopup: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    
    @IBAction func logoutBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: false)
        dismissPopup?(true)
    }
    
}
