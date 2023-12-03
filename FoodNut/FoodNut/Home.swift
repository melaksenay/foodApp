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
    var categoryScanCounts: [String: Int] = [:]
    var categoryColors: [String: UIColor] = [:]  //store colors for each category
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()  // Initialize Firestore
        
        setupPieChartData()
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

        // Fetch and set the image
        fetchImage(from: product.imageURL) { image in
            DispatchQueue.main.async {
                cell.foodImageView.image = image ?? UIImage(named: "defaultImage") // Replace "defaultImage" with your placeholder image
            }
        }

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
    
    func fetchImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            completion(UIImage(data: data))
        }.resume()
    }

    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    func makeCategoryColors() {
                // Regenerate your category colors here
                categoryColors.removeAll() // Clear existing colors

                for (category, _) in categoryScanCounts {
                    let newColor = getRandomColor()
                    categoryColors[category] = newColor
                }

                // Update the pie chart with the new data
                updatePieChart()
            }
        
        func setupPieChartData() {
            // Use the categoryScanCounts dictionary to create initial pie chart data
        //map sets dictionary to be array for the pieChart
            let dataEntries = categoryScanCounts.map { PieChartDataEntry(value: Double($0.value), label: $0.key) }

            let dataSet = PieChartDataSet(entries: dataEntries, label: "")

            // Automatic colors for each category
            dataSet.colors = dataEntries.map { entry in
                getColor(forCategory: entry.label ?? "")
            }

            dataSet.valueTextColor = UIColor.black
            dataSet.valueFont = UIFont.systemFont(ofSize: 16)

            // Assign the dataset to the chart
            pieChartView.data = PieChartData(dataSet: dataSet)
        }

        // Function to update the pie chart dynamically when a new category is added
        func updatePieChart() {
            setupPieChartData()  // Update the pie chart with the new data
        }

        // Function to get color for a category, creating a new color if needed
        func getColor(forCategory category: String) -> UIColor {
            if let existingColor = categoryColors[category] {
                return existingColor
            } else {
                let newColor = getRandomColor()
                categoryColors[category] = newColor
                return newColor
            }
        }

        // Function to generate a random color
        func getRandomColor() -> UIColor {
            return UIColor(
                red: CGFloat(drand48()),
                green: CGFloat(drand48()),
                blue: CGFloat(drand48()),
                alpha: 1.0
            )
        }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadRecentProducts()
        loadCategoryScanCounts()
        
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
    
    // Function to load category scan counts from UserDefaults
    private func loadCategoryScanCounts() {
        let defaults = UserDefaults.standard
        if let savedScans = defaults.object(forKey: "categoryScans") as? Data {
            if let decodedScans = try? JSONDecoder().decode([String: Int].self, from: savedScans) {
                categoryScanCounts = decodedScans
            }
        }
        print(categoryScanCounts)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remember to remove the listener when the view is disappearing
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
