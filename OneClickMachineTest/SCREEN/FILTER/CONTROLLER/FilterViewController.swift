//
//  FilterViewController.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import UIKit

protocol CategoryDelegate : AnyObject {
    func getValue(catId: Int, maxPrice: String, minPrice: String, categoryName: String)
}

class FilterViewController: BaseViewController {
    
    //MARK: IBOutlet
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var viewCategory: UIView!
    @IBOutlet weak var lblSelectedCategory: UILabel!
    @IBOutlet weak var txtMinPrice: UITextField!
    @IBOutlet weak var txtMaxPrice: UITextField!
    @IBOutlet weak var btnClear: UIButton!
    @IBOutlet weak var btnApply: UIButton!
    
    //MARK: Variables
    weak var delegate : CategoryDelegate?
    var selectedCategoryId : Int = 0
    var selectedCategoryName: String = "Select Category"
    var categoriesList: [CategoriesModel] = []
    var minPrice: String = ""
    var maxPrice: String = ""
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupDesign()
    }
    
    //MARK: Functions
    @objc func applyFilter() {
        self.delegate?.getValue(catId: selectedCategoryId, maxPrice: self.txtMaxPrice.text ?? "", minPrice: self.txtMinPrice.text ?? "", categoryName: self.lblSelectedCategory.text ?? "")
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func clearFilter() {
        self.txtMaxPrice.text = ""
        self.txtMinPrice.text = ""
        self.lblSelectedCategory.text = "Select Category"
        self.lblSelectedCategory.textColor = .lightGray
        self.selectedCategoryId = 0
    }
    
    func setupDesign() {
        self.categoryTableView.layer.borderWidth = 1
        self.categoryTableView.layer.borderColor = UIColor.lightGray.cgColor
        self.categoryTableView.isHidden = true
        self.txtMaxPrice.setRoundCorners(cornerRadius: 10, borderwidth: 1, bordercolor: .black)
        self.txtMinPrice.setRoundCorners(cornerRadius: 10, borderwidth: 1, bordercolor: .black)
        self.txtMaxPrice.setLeftPaddingPoints(10)
        self.txtMinPrice.setLeftPaddingPoints(10)
        self.viewCategory.layer.cornerRadius = 10
        self.viewCategory.layer.borderColor = UIColor.black.cgColor
        self.viewCategory.layer.borderWidth = 1
        self.btnApply.layer.cornerRadius = 10
        self.btnClear.layer.cornerRadius = 10
        self.btnApply.addTarget(self, action: #selector(applyFilter), for: .touchUpInside)
        self.btnClear.addTarget(self, action: #selector(clearFilter), for: .touchUpInside)
        self.txtMaxPrice.text = self.maxPrice
        self.txtMinPrice.text = self.minPrice
        if self.selectedCategoryName == "Select Category"  {
            self.lblSelectedCategory.textColor = .lightGray
        } else {
            self.lblSelectedCategory.textColor = .black
        }
        self.lblSelectedCategory.text = self.selectedCategoryName
        self.txtMaxPrice.delegate = self
        self.txtMinPrice.delegate = self
    }
    
    func animate(toogle: Bool, type: UIButton) {
        if toogle {
            UIView.animate(withDuration: 0.3) {
                self.categoryTableView.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.categoryTableView.isHidden = true
            }
        }
    }
    
    //MARK: IBActions
    @IBAction func btnCategoryTapped(_ sender: UIButton) {
        if categoryTableView.isHidden {
            animate(toogle: true, type: btnCategory)
        } else {
            animate(toogle: false, type: btnCategory)
        }
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
}

//MARK: Table View Delegates and Datasources
extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTableViewCell") as? FilterTableViewCell else {
            return UITableViewCell()
        }
        
        cell.lblCategoryName.text = categoriesList[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.lblSelectedCategory.text = categoriesList[indexPath.row].name
        self.selectedCategoryId = categoriesList[indexPath.row].id ?? 0
        self.lblSelectedCategory.textColor = .black
        animate(toogle: false, type: btnCategory)
    }
}

//MARK: Textfield Delegates
extension FilterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.txtMaxPrice.resignFirstResponder()
        self.txtMinPrice.resignFirstResponder()
        return true
    }
}
