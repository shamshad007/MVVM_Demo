//
//  ProductDetailsViewController.swift
//  OneClickMachineTest
//
//  Created by Md Shamshad Akhtar on 25/05/25.
//

import UIKit
import SDWebImage

class ProductDetailsViewController: UIViewController, UIScrollViewDelegate {
    //MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblDescriptions: UILabel!
    
    //MARK: - Variables and Constant
    var images = [String]()
    var productName: String?
    var price: String?
    var descriptions: String?
    var timer: Timer?
    var counter = 0
    
    //MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self

        // Page control count and current page
        pageControl.numberOfPages = images.count
        pageControl.currentPage = 0
        
        self.lblProductName.text = self.productName
        self.lblPrice.text = "\(self.price ?? "0") AED"
        self.lblDescriptions.text = self.descriptions
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //start Auto Scroll
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.autoScroll), userInfo: nil, repeats: true)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.timer?.invalidate()
        self.timer = nil
        UserDefaults.standard.set("isShown", forKey: "splash2")
    }
    
    //MARK: - IBActions
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }

    //MARK: - Functions
    @objc func autoScroll() {
        // Calculate the next index
        let currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.width
        let nextIndex = (currentIndex + 1).truncatingRemainder(dividingBy: CGFloat(self.images.count))

        // Scroll to the next index
        let indexPath = IndexPath(item: Int(nextIndex), section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
    
    //MARK: - Scrollview Delegates
    // Change page control when scroll manually
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.bounds.width)
        self.pageControl.currentPage = Int(pageIndex)
    }
    
}

//MARK: - Collection View Datasources
extension ProductDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductDetailsCollectionViewCell", for: indexPath) as! ProductDetailsCollectionViewCell

        let image = images[indexPath.item]
        cell.imgProduct.sd_setImage(with: URL(string: image), placeholderImage: UIImage.gif(name: "Spinner"), context: .none)
        cell.imgProduct.contentMode = .scaleToFill

        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension ProductDetailsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = self.collectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
