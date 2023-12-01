import UIKit
import DGCharts
import FirebaseAuth
import FirebaseFirestore  // Import Firestore

class Home: UIViewController {

    @IBOutlet weak var pieChartView: PieChartView!
    var handle: AuthStateDidChangeListenerHandle?
    var db: Firestore!  // Firestore database reference

    @IBOutlet weak var welcomeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()  // Initialize Firestore
        
        setupPieChartData()
    }
    
    func setupPieChartData() {
        // Sample data
        let dataEntries = [
            PieChartDataEntry(value: 40, label: "Beverages"),
            PieChartDataEntry(value: 30, label: "Snacks"),
            PieChartDataEntry(value: 30, label: "Desserts")
        ]

        let dataSet = PieChartDataSet(entries: dataEntries, label: "")

        // Customization with calmer colors
        dataSet.colors = [
            UIColor.systemGreen.withAlphaComponent(0.5), // Light green
            UIColor.systemOrange.withAlphaComponent(0.5), // Light orange
            UIColor.systemPink.withAlphaComponent(0.5)    // Light pink
        ]
        dataSet.valueTextColor = UIColor.black
        dataSet.valueFont = UIFont.systemFont(ofSize: 16)
        
        // Assign the dataset to the chart
        pieChartView.data = PieChartData(dataSet: dataSet)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up the authentication state listener
        handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let userID = user?.uid {
                // User is signed in, fetch their name from Firestore
                self?.fetchUserName(userID: userID) { name in
                    self?.welcomeLabel.text = "Welcome, \(name)"
                }
            } else {
                // No user is signed in
                self?.welcomeLabel.text = "Welcome, Guest"
            }
        }
        
        print("viewWillAppear called")
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remember to remove the listener when the view is disappearing
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
