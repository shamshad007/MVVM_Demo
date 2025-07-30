//
//  FilterTableViewCell.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import UIKit

class FilterTableViewCell: UITableViewCell {
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var viewCategory: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
