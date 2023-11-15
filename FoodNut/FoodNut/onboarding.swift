//
//  onboarding.swift
//  FoodNut
//
//  Created by Emily Brouillet on 11/13/23.
//

import Foundation
import UIKit
class onboarding: UIViewController{
    @IBOutlet weak var login: UIButton!
    
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func createAccountClicked(_ sender: Any) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabID") as! UITabBarController

            // Set the new root view controller of the window.
            window.rootViewController = tabBarController

            // A smooth transition animation to the new root view controller.
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: nil)
        }

    }
    

}
