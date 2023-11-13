//
//  onboarding.swift
//  FoodNut
//
//  Created by Emily Brouillet on 11/13/23.
//

import Foundation
import UIKit
class onboarding: UIViewController{
    @IBOutlet weak var getStarted: UIButton!
    @IBOutlet weak var login: UIButton!
    
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    override func viewDidLoad() {
        getStarted.layer.cornerRadius = 15
    }
    @IBAction func getStartedPressed(_ sender: Any) {
        
    }
}
