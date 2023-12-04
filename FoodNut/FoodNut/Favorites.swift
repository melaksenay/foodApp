//
//  Favorites.swift
//  FoodNut
//
//  Created by Logan Farrow on 12/2/23.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore




class Favorites: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var db:Firestore!
    var handle: AuthStateDidChangeListenerHandle?
    @IBOutlet weak var favoritesLabel: UILabel!
    var userid: String?
    
    var products = [FirebaseProduct]()
    
    var imageCache = [String: UIImage]()


    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        db = Firestore.firestore()
        
        favoritesLabel.layer.cornerRadius = favoritesLabel.frame.size.width / 18
        favoritesLabel.clipsToBounds = true

        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProduct = products[indexPath.item]
        let detailedVC = DetailedViewController()

        // Populate the detailed view controller with the selected product's data
        detailedVC.productName = selectedProduct.name
        detailedVC.code = selectedProduct.code
        detailedVC.nutriscore = selectedProduct.nutriscore
        detailedVC.caloriesPerServing = "Calorie content: \(selectedProduct.caloriesPerServing)"
        detailedVC.fatPerServing = "Fat content: \(selectedProduct.fatPerServing)"
        detailedVC.proteinsPerServing = "Protein content: \(selectedProduct.proteinsPerServing)"
        detailedVC.carbsPerServing = "Carb content: \(selectedProduct.carbsPerServing)"
        detailedVC.novaGroup = "Nova Group: \(selectedProduct.novaGroup)"
        detailedVC.additives = selectedProduct.additives
        detailedVC.showButton = false

        // Check for cached image
        if let cachedImage = imageCache[selectedProduct.imageURL] {
            detailedVC.productImage = cachedImage
        } else {
            detailedVC.productImage = UIImage(named: "defaultImage")
            detailedVC.imageUrl = ""
        }

        // Push the detailed view controller onto the navigation stack
        self.navigationController?.pushViewController(detailedVC, animated: true)
    }

    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        // Check cache first
        if let cachedImage = imageCache[url.absoluteString] {
            completion(cachedImage)
            return
        }

        // Download the image
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageCache[url.absoluteString] = image // Cache the image
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    
    func fetchProducts() {
        guard let userid = self.userid else {
            print("userid was null")
            return
        }

        db.collection("users").document(userid).getDocument { (documentSnapshot, err) in
            if let err = err {
                print("Error getting document: \(err)")
            } else if let document = documentSnapshot, document.exists {
                // Assuming 'userFavorites' is an array field in the document
                if let userFavorites = document.data()?["userFavorites"] as? [[String: Any]] {
                    self.products = [] // Clearing existing products

                    for data in userFavorites {
                        let product = FirebaseProduct(
                            code: data["code"] as? String ?? "",
                            name: data["name"] as? String ?? "",
                            carbsPerServing: data["carbsPerServing"] as? String ?? "",
                            fatPerServing: data["fatPerServing"] as? String ?? "",
                            proteinsPerServing: data["proteinsPerServing"] as? String ?? "",
                            caloriesPerServing: data["caloriesPerServing"] as? String ?? "",
                            nutriscore: data["nutriscore"] as? String ?? "",
                            novaGroup: data["novaGroup"] as? String ?? "",
                            additives: data["additives"] as? String ?? "",
                            imageURL: data["imageURL"] as? String ?? ""
                        )
                        self.products.append(product)
                    }
                    self.collectionView.reloadData()
                } else {
                    print("No 'userFavorites' array in the document")
                }
            } else {
                print("Document does not exist")
            }
        }
    }



    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favCell", for: indexPath) as! FavoritesCell
        
        cell.favoriteLabel.numberOfLines = 0
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        let product = products[indexPath.item]
        cell.favoriteLabel.text = product.name

        // Set a default image first, in case the cached/downloaded image takes time to load
        cell.favoriteImageView.image = UIImage(named: "defaultImage")

        // Check for cached image
        if let cachedImage = imageCache[product.imageURL] {
            cell.favoriteImageView.image = cachedImage
        } else if let url = URL(string: product.imageURL) {
            // Download and cache the image
            downloadImage(from: url) { image in
                // Make sure the cell is still visible before setting the image
                if let visibleCell = collectionView.cellForItem(at: indexPath) as? FavoritesCell {
                    visibleCell.favoriteImageView.image = image ?? UIImage(named: "defaultImage")
                }
            }
        }
        
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: indexPath.section)
        let lineSpacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: indexPath.section)
        let insets = collectionView.contentInset
        let numberOfItemsPerRow: CGFloat = 3 // Adjust as needed
        let totalSpacing = (numberOfItemsPerRow - 1) * spacing
        let totalInset = insets.left + insets.right

        let availableWidth = collectionView.frame.width - totalSpacing - totalInset
        let widthPerItem = availableWidth / numberOfItemsPerRow
        let heightPerItem = (widthPerItem * 1.5) - lineSpacing // Adjust height according to line spacing

        return CGSize(width: widthPerItem, height: heightPerItem)
    }


    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //items per section in collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    // Adjusts the spacing between items in the same row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    // Adjusts the spacing between lines in the grid
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }


    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up the authentication state listener
        handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let userID = user?.uid {
                // User is signed in
                self?.userid = userID
                // Fetch products after confirming the user is signed in
                self?.fetchProducts()
            } else {
                // No user is signed in
                self?.userid = nil
                print("no user")
            }
        }
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remember to remove the listener when the view is disappearing
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        
    }
    
    
    
    
    


}
