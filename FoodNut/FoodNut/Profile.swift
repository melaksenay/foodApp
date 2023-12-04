//
//  Profile.swift
//  FoodNut
//
//  Created by Logan Farrow on 11/30/23.
//

import UIKit
import FirebaseAuth

class Profile: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var updateProfile: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.clipsToBounds = true
        nameLabel.layer.cornerRadius = nameLabel.frame.size.width / 18
        nameLabel.clipsToBounds = true
        updateProfile.layer.cornerRadius = updateProfile.frame.size.width / 18
        updateProfile.clipsToBounds = true
        logoutButton.layer.cornerRadius = logoutButton.frame.size.width / 18
        logoutButton.clipsToBounds = true
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up the authentication state listener
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            // Handle authentication state
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remember to remove the listener when the view is disappearing
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    
        
        
    
    
    
    @IBAction func logoutButtonClicked(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            // Navigate to the login screen with the storyboard ID 'Welcome'
            if let welcomeViewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "Welcome") as? Weclome {
                // Assuming that 'WelcomeViewController' is the class of your login screen
                navigationController?.pushViewController(welcomeViewController, animated: true)
            }
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    


}
