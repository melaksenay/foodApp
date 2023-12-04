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
    var userid: String?
    
    var products = [FirebaseProduct]()

    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        db = Firestore.firestore()

        
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


    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    completion(UIImage(data: data))
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favCell", for: indexPath) as! FavoritesCell
        
        //cell.favoriteLabel.layer.cornerRadius = cell.favoriteLabel.frame.size.width / 18
        //cell.favoriteLabel.clipsToBounds = true
        cell.favoriteLabel.numberOfLines = 0
        
        
        let product = products[indexPath.item]
            cell.favoriteLabel.text = product.name

            cell.favoriteImageView.image = UIImage(named: "todd")
        
            // Load image from URL
            if let url = URL(string: product.imageURL) {
                downloadImage(from: url) { image in
                    // Make sure the cell is still visible before setting the image
                    if let visibleCell = collectionView.cellForItem(at: indexPath) as? FavoritesCell {
                        visibleCell.favoriteImageView.image = image
                    }
                }
            }
        
        
        
        
        return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = collectionView.frame.size.width / 3
            let height = width * 1.5
            return CGSize(width: width, height: height)
        }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //items per section in collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1 // Your desired spacing between cells
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1 // Your desired spacing between lines
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
