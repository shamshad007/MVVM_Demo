//
//  UITextField.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import UIKit

public extension UITextField {
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    func setRoundCorners(cornerRadius : Double,borderwidth :  Double,bordercolor :UIColor){
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.layer.borderWidth = CGFloat(borderwidth)
        self.layer.borderColor = bordercolor.cgColor
        self.layer.masksToBounds = true
    }
    
}
