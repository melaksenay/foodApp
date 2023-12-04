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
        headerLabel.text = "NutriScore Philosophy"
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
        let attributedString = NSMutableAttributedString(string: "Quick and Dirty:\n\n", attributes: boldFontAttribute)
        attributedString.append(NSAttributedString(string: "\(quickAndDirty)\n\n", attributes: regularFontAttribute))
        attributedString.append(NSAttributedString(string: "Some More Detail:\n\n", attributes: boldFontAttribute))
        attributedString.append(NSAttributedString(string: "About NutriScore System:\n\n", attributes: boldFontAttribute))
           attributedString.append(NSAttributedString(string: "\(aDescription)\n\n", attributes: regularFontAttribute))
           attributedString.append(NSAttributedString(string: "Insights from NutriScore:\n\n", attributes: boldFontAttribute))
        attributedString.append(NSAttributedString(string: "\(bDescription)\n\n", attributes: regularFontAttribute))

           return attributedString
       }
}

// Definitions for each rank's description
let aDescription = """
- Utilizes a 5-category ranking (A to E) to indicate nutritional quality of food products.
- Category A (best) to E (worst) based on content of key nutrients.
- Developed from the British Food Standards Agency system.
- Factors in energy, saturated fats, sugars, sodium, fibers, proteins, and presence of fruits, vegetables, legumes, nuts.
- Aimed at guiding healthier food choices and preventing chronic diseases.
"""

let bDescription = """
- Higher scores (D and E) are linked to increased health risks, including cancer and mortality from various chronic diseases.
- Nutri-Score effectively rates nutritional quality across different food categories and dietary patterns globally.
- Selecting products rated A or B can lead to healthier dietary choices and reduce the risk of chronic diseases.
"""

let quickAndDirty = """
- Score A: Healthy food. Can be eaten every day.
- Score B: Healthy food. Slightly processed, but not harmful.
- Score C: Not dangerous enough to be labeled D or E, enjoy occasionally!
- Score D: Harmful if eaten in the long-term. Enjoy occasionally.
- Score E: Dangerous if eaten in the long-term. Try to cut out of your diet.
"""


