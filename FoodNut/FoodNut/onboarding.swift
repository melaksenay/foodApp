import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore

class onboarding: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var accountLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    // Add a boolean to keep track of the user's intention (login or create account)
    var isLogin = false
    var db:Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup initial state
        toggleLoginCreate(isLogin: isLogin)
        
        infoLabel.text = "Passwords must be at least 6 characters in length, include one capital letter, and include one numeric character."
        
        db = Firestore.firestore()
    }
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        isLogin.toggle() // Toggle the state between login and create account
        toggleLoginCreate(isLogin: isLogin)
    }
    
    @IBAction func createAccountClicked(_ sender: Any) {
        // Check for empty fields
        guard let email = emailInput.text, !email.isEmpty,
              let password = passwordInput.text, !password.isEmpty else {
            self.infoLabel.text = "Email and Password must be filled out."
            return
        }
        
        if isLogin {
            // Login the existing user
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    strongSelf.infoLabel.text = error.localizedDescription
                    // Handle errors by showing an alert to the user
                } else {
                    // Proceed with transitioning to the main view controller
                    strongSelf.transitionToMainInterface()
                }
            }
        } else {
            // No need to check for name if logging in
            guard let name = nameInput.text, !name.isEmpty else {
                self.infoLabel.text = "Fill out name"
                return
            }
            
            // Create the new user account
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                if let error = error {
                    self?.infoLabel.text = error.localizedDescription
                    // Handle errors by showing an alert to the user
                } else {
                    // Proceed with transitioning to the main view controller
                    self?.transitionToMainInterface()

                    // Add user to the database
                    if let userID = authResult?.user.uid {
                        self?.db.collection("users").document(userID).setData([
                            "name": name,
                            "photo": "url_of_the_photo",
                            "userFavorites": [], // Empty string array
                            "recentScans": [String](), // Empty string array
                            "totalItemsScanned": 0
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written with ID: \(userID)")
                            }
                        }
                    }
                }
            }
        }
    }


    
    func toggleLoginCreate(isLogin: Bool) {
        nameInput.isHidden = isLogin
        createAccountButton.setTitle(isLogin ? "Login" : "Create Account", for: .normal)
        loginButton.setTitle(isLogin ? "Create Account" : "Login", for: .normal)
        accountLabel.text = isLogin ? "Already have an account?" : "Need an account?"
        
    }
    
    func transitionToMainInterface() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabID") as! UITabBarController

            window.rootViewController = tabBarController

            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {}, completion: nil)
        }
    }
    @IBAction func skipButtonClicked(_ sender: Any) {
        transitionToMainInterface()
        
    }
}
