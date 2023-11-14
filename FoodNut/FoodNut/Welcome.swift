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
        performSegue(withIdentifier: "toOnboarding", sender: self)
    }
    
}
