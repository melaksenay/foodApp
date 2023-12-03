//
//  DetailedViewController.swift
//  FoodNut
//
//  Created by Mitchell vom Scheidt on 11/8/23.
//

import UIKit

class DetailedViewController: UIViewController {
    var code: String?
    var productName: String?
    var carbsPerServing: String?
    var fatPerServing: String?
    var proteinsPerServing: String?
    var caloriesPerServing: String?
    var nutriscore: String?
    var novaGroup: String?
    var ingredients: String?
    
    var productImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        print("DetailedViewController loaded with data: Code - \(code ?? "nil"), Calories - \(caloriesPerServing ?? "nil"), Fat - \(fatPerServing ?? "nil"), Proteins - \(proteinsPerServing ?? "nil"), Carbs - \(carbsPerServing ?? "nil"), Image - \(String(describing: productImage))")
        setupUI()
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
        let ingredientsLable = createLabel(withText: "\(ingredients ?? "Not available")")
        
        [imageView, nameLabel, carbsLabel, fatLabel, proteinLabel, caloriesLabel, nutriscoreLabel, novaLabel, ingredientsLable].forEach { stackView.addArrangedSubview($0) }
    }
    
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0 //label can wrap if text is longgg
        return label
    }
}
