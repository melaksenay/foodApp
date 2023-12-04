//
//  DetailedViewController.swift
//  FoodNut
//
//  Created by Mitchell vom Scheidt on 11/8/23.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore  // Import Firestore

struct FirebaseProduct {
    var code: String
    var name: String
    var carbsPerServing: String
    var fatPerServing: String
    var proteinsPerServing: String
    var caloriesPerServing: String
    var nutriscore: String
    var novaGroup: String
    var additives: String

    var dictionary: [String: Any] {
        return [
            "code": code,
            "name": name,
            "carbsPerServing": carbsPerServing,
            "fatPerServing": fatPerServing,
            "proteinsPerServing": proteinsPerServing,
            "caloriesPerServing": caloriesPerServing,
            "nutriscore": nutriscore,
            "novaGroup": novaGroup,
            "additives": additives
        ]
    }
}


class DetailedViewController: UIViewController, UITableViewDataSource {
    var code: String?
    var productName: String?
    var carbsPerServing: String?
    var fatPerServing: String?
    var proteinsPerServing: String?
    var caloriesPerServing: String?
    var nutriscore: String?
    var novaGroup: String?
    var ingredients: String?
    var additives: String?
    
    var productImage: UIImage?
    
    var db:Firestore!
    var handle: AuthStateDidChangeListenerHandle?
    var userid: String?
    
    let addToFavoritesButton = UIButton(type: .system)
    var tableView: UITableView!
    
    var nutritionDetails: [(String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Prepare the nutrition details
        nutritionDetails = [
            (productName ?? "Not available"),
            (carbsPerServing ?? "Not available"),
            (fatPerServing ?? "Not available"),
            (proteinsPerServing ?? "Not available"),
            (caloriesPerServing ?? "Not available"),
            (nutriscore ?? "Not available"),
            (novaGroup ?? "Not available"),
            (additives ?? "Not available")
        ]
        
        setupAddToFavoritesButton()
        setupUI()
    }
    
    private func setupAddToFavoritesButton() {
           addToFavoritesButton.setTitle("Add to Favorites", for: .normal)  // Set button title
           addToFavoritesButton.addTarget(self, action: #selector(addToFavoritesTapped), for: .touchUpInside)  // Button add
           
           view.addSubview(addToFavoritesButton)  // Add the button to the view hierarchy
           
           addToFavoritesButton.translatesAutoresizingMaskIntoConstraints = false  // Disable autoresizing mask translation
           
           // Set up constraints to position the button at the bottom right corner
           NSLayoutConstraint.activate([
               addToFavoritesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
               addToFavoritesButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
           ])
       }
    
    @objc func addToFavoritesTapped() {
        guard let userID = userid else {
            print("User not logged in")
            return
        }

        let product = FirebaseProduct(
            code: code ?? "",
            name: productName ?? "",
            carbsPerServing: carbsPerServing ?? "",
            fatPerServing: fatPerServing ?? "",
            proteinsPerServing: proteinsPerServing ?? "",
            caloriesPerServing: caloriesPerServing ?? "",
            nutriscore: nutriscore ?? "",
            novaGroup: novaGroup ?? "",
            additives: additives ?? ""
        )

        let userRef = db.collection("users").document(userID)
        userRef.updateData([
            "userFavorites": FieldValue.arrayUnion([product.dictionary])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }

    
    private func setupUI() {
        // Initialize image view
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = productImage
        
        // Initialize table view
        tableView = UITableView()
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NutritionDetailCell")
        
        // Add subviews
        view.addSubview(imageView)
        view.addSubview(tableView)
        
        // Set up the image view constraints
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
        
        // Set up the table view constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: addToFavoritesButton.topAnchor, constant: -20)
        ])
    }
    
    private func setupAddToFavoritesButton() {
        addToFavoritesButton.setTitle("Add to Favorites", for: .normal)
        addToFavoritesButton.addTarget(self, action: #selector(addToFavoritesTapped), for: .touchUpInside)
        
        view.addSubview(addToFavoritesButton)
        
        addToFavoritesButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addToFavoritesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addToFavoritesButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    @objc func addToFavoritesTapped() {
        print("Add to Favorites tapped!")
        // Add the logic to handle the tap event for adding to favorites
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nutritionDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NutritionDetailCell", for: indexPath)
        let nutritionDetail = nutritionDetails[indexPath.row]
        cell.textLabel?.text = "\(nutritionDetail)"
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up the authentication state listener
        handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let userID = user?.uid {
                // User is signed in
                self?.userid = userID
            } else {
                // No user is signed in
                self?.userid = nil
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
