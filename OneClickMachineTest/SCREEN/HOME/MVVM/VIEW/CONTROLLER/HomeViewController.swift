//
//  HomeViewController.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import UIKit
import SDWebImage
import Combine
import SwiftKeychainWrapper

class HomeViewController: BaseViewController, UITextFieldDelegate {
    
    //MARK: - IBOutlet
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var collectionViewList: UICollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    //MARK: - Variables and Constants
    let numberOfColumns : CGFloat = 2
    var categoriesResponse = [CategoriesModel]()
    var productResponse = [ProductListModel]()
    let refreshControl = UIRefreshControl()
    var offset : Int = 0
    var limit : Int = 10
    var isloading : Bool = false
    var catId : Int = 0
    var maxPrice: String = ""
    var minPrice: String = ""
    var selectedCategoryName: String = ""
    var filteredArray = [ProductListModel]()
    // Sample data - each array represents images for one slider
    private var imageGroups: [[UIImage]] = []
    // use this to track the currently selected item / cell
    var currentSelection: IndexPath!
    
    //MARK: - View Model Object
    var categoriesViewModel: CategoriesViewModel = .init()
    var productViewModel: ProductViewModel = .init()
    var cancellable: Set<AnyCancellable> = .init()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupView()
        self.showLoader(text: "Loading...")
        self.categoriesViewModel.fetchCategoriesDetails()
        self.productViewModel.fetchProductListDetails(offset: "\(offset)", limit: "\(limit)", priceMin: self.minPrice, priceMax: self.maxPrice, categoryId: "\(self.catId)")
        self.subscribeToProductListDetails()
        self.subscribeToCategoriesDetails()
        self.checkApiError()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let flowLayout = self.collectionViewList?.collectionViewLayout as? UICollectionViewFlowLayout {
            let horizontalSpacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
            let cellWidth = (self.collectionViewList.frame.width - max(0, self.numberOfColumns - 1) * horizontalSpacing)/self.numberOfColumns
            flowLayout.itemSize = CGSize(width: cellWidth, height: 250)
        }
    }
    
    //MARK: Functions
    func setupView() {
        self.navigationController?.navigationBar.isHidden = true
        self.viewSearch.layer.cornerRadius = 10
        self.viewSearch.layer.borderWidth = 1
        self.viewSearch.layer.borderColor = UIColor.black.cgColor
        self.btnProfile.sd_setImage(with: URL(string: UserDefaultsManager.shared.getStringValue(forKey: UserDefaultsKey.avatar)), for: .normal)
        self.lblTitle.text = "Hi, \(UserDefaultsManager.shared.getStringValue(forKey: UserDefaultsKey.name).capitalized)"
        self.btnProfile.layer.cornerRadius = self.btnProfile.frame.height/2
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.tintColor = .systemBlue
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        // Add to CollectionView
        collectionViewList.refreshControl = refreshControl
        
        txtSearch.delegate = self
        txtSearch.addTarget(self, action: #selector(searchRecords(_ :)), for: .editingChanged)
        btnLogout.addTarget(self, action: #selector(Logout), for: .touchUpInside)
    }
    
    func reloadCollectionView() {
        // Get all selected index paths
        let selectedIndexPaths = categoryCollectionView.indexPathsForSelectedItems ?? []
        
        // Deselect all selected items
        for indexPath in selectedIndexPaths {
            categoryCollectionView.deselectItem(at: indexPath, animated: true)
        }
        
        // Reload data
        categoryCollectionView.reloadData()
    }
    
    //MARK: TextField Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtSearch.resignFirstResponder()
        return true
    }
    
    //MARK: - Logout
    @objc func Logout() {
        let sb = UIStoryboard(name: "Logout", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "LogoutVC") as? LogoutVC {
            vc.modalPresentationStyle = .overFullScreen
            vc.dismissPopup = { _ in
                // remove locally saved data
                KeychainWrapper.standard.removeObject(forKey: "access_token")
                UserDefaultsManager.shared.removeValue(forKey: UserDefaultsKey.name)
                UserDefaultsManager.shared.removeValue(forKey: UserDefaultsKey.email)
                UserDefaultsManager.shared.removeValue(forKey: UserDefaultsKey.avatar)
                let sb = UIStoryboard(name: "Login", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
            self.present(vc, animated: false)
        }
    }
    
    //MARK:- searchRecords
    @objc func searchRecords(_ textField: UITextField) {
        productResponse.removeAll()
        if textField.text?.count != 0 {
            for list in filteredArray {
                if let listToSearch = textField.text {
                    let range = list.title?.lowercased().range(of: listToSearch, options: .caseInsensitive, range: nil, locale: nil)
                    if range != nil {
                        productResponse.append(list)
                    }
                }
            }
        } else {
            for list in filteredArray {
                productResponse.append(list)
            }
        }
        
        collectionViewList.reloadData()
    }
    
    //MARK: - Pull to refresh
    @objc private func refreshData(_ sender: Any) {
        // Fetch new data
        fetchData { [weak self] in
            DispatchQueue.main.async {
                self?.collectionViewList.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    private func fetchData(completion: @escaping () -> Void) {
        // Your data fetching logic here
        self.productViewModel.fetchProductListDetails(offset: "0", limit: "10", priceMin: self.minPrice, priceMax: self.maxPrice, categoryId: "\(self.catId)")
        completion()
    }
    
    //MARK: IBAction
    @IBAction func btnFilterTapped(_ sender: UIButton) {
        self.txtSearch.resignFirstResponder()
        self.txtSearch.text = ""
        let sb = UIStoryboard(name: "Filter", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController {
            vc.categoriesList = self.categoriesResponse
            vc.delegate = self
            vc.selectedCategoryId = self.catId
            vc.minPrice = self.minPrice
            vc.maxPrice = self.maxPrice
            vc.selectedCategoryName = self.selectedCategoryName
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - Collection View Delegates and Datasources
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionViewList {
            return self.productResponse.count
        } else {
            return self.categoriesResponse.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionViewList {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as? HomeCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let productData = self.productResponse[indexPath.row]
            
            cell.imgProduct.sd_setImage(with: URL(string: productData.images?.first ?? ""), placeholderImage: UIImage.gif(name: "Spinner"), context: .none)
            cell.viewProductList.layer.cornerRadius = 8
            cell.lblTite.text = "\(productData.title ?? "")"
            cell.lblPrice.text = "Price: \(productData.price ?? 0) AED"
            cell.lblDescriptions.text = "Descriptions: \(productData.description ?? "")"
            self.shadowOnUIView(name: cell.viewProductList)
            self.collectionHeight.constant = self.collectionViewList.contentSize.height
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as? CategoryCollectionViewCell else {
                return UICollectionViewCell()
            }
            self.shadowOnUIView(name: cell.viewCategory)
            
            let categoryData = self.categoriesResponse[indexPath.row]
            
            cell.imgCategory.sd_setImage(with: URL(string: categoryData.image ?? ""), placeholderImage: UIImage.gif(name: "Spinner"), context: .none)
            cell.lblCategory.text = categoryData.name
            cell.imgCategory.layer.cornerRadius = cell.imgCategory.frame.height / 2
            
            return cell
        } 
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.categoryCollectionView {
            self.catId = self.categoriesResponse[indexPath.row].id ?? 0
            self.selectedCategoryName = self.categoriesResponse[indexPath.row].name ?? ""
            self.productResponse.removeAll()
            self.offset = 0
            self.limit = 10
            self.productViewModel.fetchProductListDetails(offset: "\(self.offset)", limit: "\(self.limit)", priceMin: self.minPrice, priceMax: self.maxPrice, categoryId: "\(self.catId)")
            
            collectionView.cellForItem(at: indexPath)?.isSelected = true
        } else {
            self.txtSearch.resignFirstResponder()
            self.txtSearch.text = ""
            let sb = UIStoryboard(name: "ProductDetails", bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController {
                vc.productName = self.productResponse[indexPath.row].title ?? ""
                vc.price = "\(self.productResponse[indexPath.row].price ?? 0)"
                vc.descriptions = self.productResponse[indexPath.row].description ?? ""
                vc.images = self.productResponse[indexPath.row].images ?? []
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.isSelected = false
    }
}

//MARK: - Subscribe to get Api Responses
extension HomeViewController {
    // get categories Details response
    func subscribeToCategoriesDetails() {
        self.categoriesViewModel.$categoriesResponse.sink { [weak self] responseData in
            guard self != nil else {return}
            if let response = responseData {
                debugPrint("Categories details data: \(response)")
                self?.categoriesResponse = response
                
                DispatchQueue.main.async {
                    self?.categoryCollectionView.reloadData()
                }
            }
            self?.hideLoader()
        }
        .store(in: &self.cancellable)
    }
    
    // get Product Details response
    func subscribeToProductListDetails() {
        self.productViewModel.$productResponse.sink { [weak self] responseData in
            guard self != nil else {return}
            if let response = responseData {
                debugPrint("Product details data: \(response)")
                self?.productResponse += response
                self?.filteredArray = self?.productResponse ?? []
                DispatchQueue.main.async {
                    self?.collectionViewList.reloadData()
                }
            }
            self?.hideLoader()
        }
        .store(in: &self.cancellable)
    }
    
    // api error handling
    func checkApiError() {
        self.categoriesViewModel.authentication_error.sink { response in
            self.showAlertWithTextAtController(vc: self , title: response.errorDescription ?? "", message: "")
            self.hideLoader()
        }
        .store(in: &self.cancellable)
    }
}

//MARK: - Scrollview Delegates
extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= self.collectionViewList.frame.height * CGFloat(offset / limit) && self.productResponse.count != 0 {
            self.offset = self.offset + limit
            self.productViewModel.fetchProductListDetails(offset: "\(self.offset)", limit: "\(self.limit)", priceMin: self.minPrice, priceMax: self.maxPrice, categoryId: "\(self.catId)")
        }
    }
}

//MARK: - Filter Delegates
extension HomeViewController: CategoryDelegate {
    func getValue(catId: Int, maxPrice: String, minPrice: String, categoryName: String) {
        self.reloadCollectionView()
        self.catId = catId
        self.maxPrice = maxPrice
        self.minPrice = minPrice
        self.selectedCategoryName = categoryName
        self.offset = 0
        self.limit = 10
        self.productResponse.removeAll()
        self.productViewModel.fetchProductListDetails(offset: "\(self.offset)", limit: "\(self.limit)", priceMin: self.minPrice, priceMax: self.maxPrice, categoryId: "\(self.catId)")
    }
}
