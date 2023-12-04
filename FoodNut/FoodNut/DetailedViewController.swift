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
    var imageURL: String

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
            "additives": additives,
            "imageURL": imageURL
        ]
    }
}


class DetailedViewController: UIViewController {
    var code: String?
    var productName: String?
    var carbsPerServing: String?
    var fatPerServing: String?
    var proteinsPerServing: String?
    var caloriesPerServing: String?
    var nutriscore: String?
    var novaGroup: String?
    var ingredients: String? //might be deprecated.
    var additives: String?
    var imageUrl: String?
    
    
    var productImage: UIImage?
    
    var db:Firestore!
    var handle: AuthStateDidChangeListenerHandle?
    var userid: String?
    
    let addToFavoritesButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        db = Firestore.firestore()
        
//        print("DetailedViewController loaded with data: Code - \(code ?? "nil"), Calories - \(caloriesPerServing ?? "nil"), Fat - \(fatPerServing ?? "nil"), Proteins - \(proteinsPerServing ?? "nil"), Carbs - \(carbsPerServing ?? "nil"), Image - \(String(describing: productImage))")
        setupUI()
        setupAddToFavoritesButton()
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
            additives: additives ?? "",
            imageURL: imageUrl ?? ""
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
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        // Constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
        
        // Create and add UIImageView to the stackView
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = productImage
        imageView.sizeToFit()
        
        // Create and add labels to the stackView
        let nameLabel = createLabel(withText: "\(productName ?? "Not available")")
        let carbsLabel = createLabel(withText: "\(carbsPerServing ?? "Not available")")
        let fatLabel = createLabel(withText: "\(fatPerServing ?? "Not available")")
        let proteinLabel = createLabel(withText: "\(proteinsPerServing ?? "Not available")")
        let caloriesLabel = createLabel(withText: "\(caloriesPerServing ?? "Not available")")
        let nutriscoreLabel = createLabel(withText: "\(nutriscore ?? "Not available")")
        let novaLabel = createLabel(withText: "\(novaGroup ?? "Not available")")
        let additiveLabel = createLabel(withText: "\(additives ?? "Not available")")
//        let ingredientsLable = createLabel(withText: "\(ingredients ?? "Not available")")
        
        [imageView, nameLabel, carbsLabel, fatLabel, proteinLabel, caloriesLabel, nutriscoreLabel, novaLabel, additiveLabel].forEach { stackView.addArrangedSubview($0) }
    }
    
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0 //label can wrap if text is longgg
        return label
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
