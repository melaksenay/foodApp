//
//  Welcome.swift
//  FoodNut
//
//  Created by Logan Farrow on 11/13/23.
//

import Foundation
import UIKit

class Weclome : UIViewController{
    
    
    @IBOutlet weak var getStartedButton: UIButton!
    
    override func viewDidLoad() {
        getStartedButton.layer.cornerRadius = 15
            
    }
    
    @IBAction func getStartedPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your storyboard name if it's different
        if let onboardingVC = storyboard.instantiateViewController(withIdentifier: "onboarding") as? onboarding {
            // Assuming you're using a storyboard with the "onboarding" identifier set for your onboarding view controller.
            
            // Now, set the onboardingVC as the root view controller
            if let window = view.window {
                window.rootViewController = onboardingVC
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: nil)
            }
        } else {
            // Handle errors, like the identifier not being set, or the cast failing because of a wrong class type
            print("Could not instantiate view controller with identifier 'onboarding'. Make sure you've set the identifier correctly in the storyboard.")
        }
    }

    
}
