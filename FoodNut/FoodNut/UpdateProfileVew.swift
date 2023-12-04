//
//  UpdateProfileVew.swift
//  FoodNut
//
//  Created by Emily Brouillet on 12/3/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class UpdateProfileVew: UIViewController {
    var handle: AuthStateDidChangeListenerHandle?
    var db: Firestore!
    var userid: String?
    
    @IBOutlet weak var currentUsername: UITextField!
    @IBOutlet weak var newUsername: UITextField!
    
    @IBOutlet weak var confirmButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        confirmButton.layer.cornerRadius = confirmButton.frame.size.width / 18
        confirmButton.clipsToBounds = true
        // Do any additional setup after loading the view.
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
    
    func fetchUserName(userID: String, completion: @escaping (String) -> Void) {
        // Access the user's document using their UID
        db.collection("users").document(userID).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let name = data?["name"] as? String ?? "User"
                completion(name)
            } else {
                print("Document does not exist")
                completion("User")
            }
        }
    }
    
    func changeUserName(userID: String, newUsername: String, completion: @escaping (String) -> Void) {
        // Update the user's document with the new username
        db.collection("users").document(userID).updateData(["name": newUsername]) { error in
            if let error = error {
                print("Error updating username: \(error.localizedDescription)")
                completion("User") // Return the default username in case of an error
            } else {
                print("Username updated successfully")
                completion(newUsername) // Return the updated username
            }
        }
    }
    
    @IBAction func confirmButtonClicked(_ sender: Any) {
        guard let userID = userid else {
            // Handle the case where the user is not signed in
            return
        }

        let newUsernameValue = newUsername.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Check if the new username is empty
        if newUsernameValue.isEmpty {
            showError(message: "Please enter a new username.")
            return
        }

        // Fetch the current username for comparison
        fetchUserName(userID: userID) { [weak self] currentUsername in
            guard let self = self else { return }

            // Check if the new username is equal to the current username
            if newUsernameValue.lowercased() != currentUsername.lowercased() {
                self.showError(message: "New username must match the current username.")
                return
            }

            // Proceed to change the username in Firebase
            self.changeUserName(userID: userID, newUsername: newUsernameValue) { updatedUsername in
                // Handle the case after the username has been successfully updated
                print("Username updated to: \(updatedUsername)")
            }
        }
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remember to remove the listener when the view is disappearing
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
