import UIKit
import FirebaseAuth

class Home: UIViewController {

    var handle: AuthStateDidChangeListenerHandle?

    @IBOutlet weak var welcomeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up the authentication state listener
        handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let userEmail = user?.email {
                // User is signed in, update the welcome label
                self?.welcomeLabel.text = "Welcome, \(userEmail)"
            } else {
                // No user is signed in
                self?.welcomeLabel.text = "Welcome, Guest"
            }
        }
        
        print("viewWillAppear called")
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remember to remove the listener when the view is disappearing
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    
    
}
