import UIKit
import DGCharts
import FirebaseAuth
import FirebaseFirestore  // Import Firestore

class Home: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var pieChartView: PieChartView!
    var handle: AuthStateDidChangeListenerHandle?
    var db: Firestore!  // Firestore database reference
    var recentProductIDs: [String] = []

    @IBOutlet weak var recentsCollectionView: UICollectionView!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    var recentProducts: [productStorage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()  // Initialize Firestore
        
        setupPieChartData()
        loadRecentProducts()
    }
    
    // Function to load recent products from UserDefaults
        private func loadRecentProducts() {
            let defaults = UserDefaults.standard
            if let savedProducts = defaults.object(forKey: "savedProducts") as? Data {
                if let decodedProducts = try? JSONDecoder().decode([productStorage].self, from: savedProducts) {
                    recentProducts = decodedProducts
                }
            }
            recentsCollectionView.reloadData()
            
            print(recentProducts)
        }

    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "scanCell", for: indexPath) as! RecentsCollectionViewCell
            
        let product = recentProducts[indexPath.item]
        
        cell.foodNameLabel.text = product.name

        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //items per section in collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recentProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 2.5
        let height = width * 1.75
        return CGSize(width: width, height: height)
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
