//
//  CategoryCollectionViewCell.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgCategory: UIImageView!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var viewCategory: UIView!
    
    override var isSelected: Bool {
        didSet {
            viewCategory.backgroundColor = isSelected ? .systemTeal : .white
            lblCategory.textColor = isSelected ? .white : .black
        }
    }
    
}
