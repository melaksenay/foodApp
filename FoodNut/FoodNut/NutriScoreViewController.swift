//
//  NutriScoreViewController.swift
//  FoodNut
//
//  Created by Melak Senay on 12/3/23.
//

import Foundation
import UIKit

class NutriScoreViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    private func setupUI() {
        // Create a UIScrollView to allow scrolling if content is too long
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Create and set up the header label
        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = "NOVA Philosophy"
        headerLabel.font = UIFont.boldSystemFont(ofSize: 24)
        headerLabel.textAlignment = .center
        scrollView.addSubview(headerLabel)
        
        // Create and set up the body label
        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.attributedText = createAttributedBodyText()
        bodyLabel.numberOfLines = 0
        bodyLabel.textAlignment = .left // Ensures all text within bodyLabel is left-aligned
        scrollView.addSubview(bodyLabel)
        
        // Set up constraints for the scroll view
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Set up constraints for the header label
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            headerLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor) // Centering horizontally in the scroll view
        ])
        
        // Set up constraints for the body label
        NSLayoutConstraint.activate([
            bodyLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            bodyLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            bodyLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor) // Important for scroll view content size
        ])
    }

    private func createAttributedBodyText() -> NSAttributedString {
           let boldFontAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
           let regularFontAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
           
           let attributedString = NSMutableAttributedString(string: "Group 1: Unprocessed or minimally processed ingredients\n\n", attributes: boldFontAttribute)
           attributedString.append(NSAttributedString(string: "\(aDescription)\n\n", attributes: regularFontAttribute))
           attributedString.append(NSAttributedString(string: "Group 2: Processed culinary ingredients\n\n", attributes: boldFontAttribute))
        attributedString.append(NSAttributedString(string: "\(bDescription)\n\n", attributes: regularFontAttribute))
        attributedString.append(NSAttributedString(string: "Group 3: Processed foods\n\n", attributes: boldFontAttribute))
        attributedString.append(NSAttributedString(string: "\(cDescription)\n\n", attributes: regularFontAttribute))
        attributedString.append(NSAttributedString(string: "Group 4: Ultra-processed food and drink products\n\n", attributes: boldFontAttribute))
        attributedString.append(NSAttributedString(string: "\(dDescription)\n\n", attributes: regularFontAttribute))

           return attributedString
       }
}

// Definitions for each rank's description
let aDescription = """
- Comprises whole, unaltered foods or those with minimal processing
- Includes fresh fruits, vegetables, grains, legumes, meats, and dairy
- Processes used don't add external substances like salt, sugar, or fats
- Aims to extend the natural food's life and aid in culinary preparation
- Encourages health and wellness through nutrient-rich, natural food consumption
"""

let bDescription = """
- Contains processed ingredients derived from natural foods or nature
- Used to prepare, season, and cook, enhancing the flavor of dishes
- Rarely consumed on their own, used in conjunction with Group 1 foods
- Can include salt, sugar, oils, and preservatives to maintain product quality
- Integral for diverse and flavorful home-cooked meals and recipes
"""

let cDescription = """
- Simple processed foods with added sugars, oils, or salts
- Includes canned vegetables, cured meats, and freshly made bread
- Manufactured to extend durability or enhance sensory qualities
- Should be consumed in balance with Group 1 foods for nutritional benefits
- Offers convenience but may contain preservatives for longer shelf life
"""

let dDescription = """
- Industrial formulations with multiple additives and ingredients
- Ingredients aim to mimic or enhance flavors and sensory appeal
- Often replace natural foods with ready-to-eat or heat options
- High in palatability but low in nutritional value; limit intake
- Typically packaged attractively with aggressive marketing tactics
"""

