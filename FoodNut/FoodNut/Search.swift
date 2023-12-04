//
//  Search.swift
//  FoodNut
//
//  Created by Logan Farrow on 12/2/23.
//

import UIKit

struct searchResponse: Decodable {
    let numResults: Int
    let results: [product]
    
    private enum CodingKeys: String, CodingKey {
        case numResults = "count"
        case results = "products"
        
    }
    
}

struct product: Decodable {
    var code: String
    var productName: String
    var brands: String?
    var imageUrl: String?
    var nutriscore: Int?
    var calories: Int?
    var fat: Int?
    var protein: Int?
    var carbs: Int?
    var novaGroup: Int?

    private enum CodingKeys: String, CodingKey {
        case code = "code"
        case productName = "product_name"
        case brands = "brands"
        case imageUrl = "image_front_url" // Or any other image field you prefer
        case nutriscore = "nutriscore_grade"
        case calories = "energy-kcal"
        case fat = "fat"
        case protein = "proteins"
        case carbs = "carbohydrates"
        case novaGroup = "nova-group"
    }
}


class Search: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    let dangerousAdditives : [[String]] = [
        ["E202 - Potassium sorbate", "High risk of over exposure"],
        ["E450 - Diphosphates", "High risk of over exposure"],
        ["E407 - Carrageenan", "High risk of over exposure"],
        ["E250 - Sodium nitrite", "High risk of over exposure"],
        ["E129 - Allura red", "No or very low risk of over exposure"],
        ["E150c - Ammonia caramel", "Moderate risk of over exposure"],
        ["E133 - Brilliant blue FCF", "Moderate risk of over exposure"],
        ["E211 - Sodium benzoate", "High risk of over exposure"],
        ["E341 - Calcium phosphates", "High risk of over exposure"],
        ["E621 - Monosodium glutamate", "High risk of over exposure"],
        ["E316 - Sodium erythorbate", "No or very low risk of over exposure"],
        ["E200 - Sorbic acid", "High risk of over exposure"],
        ["E452 - Polyphosphates", "High risk of over exposure"],
        ["E481 - Sodium stearoyl-2-lactylate", "High risk of over exposure"],
        ["E223 - Sodium metabisulphite", "High risk of over exposure"],
        ["E435 - Polyoxyethylene sorbitan monostearate", "Moderate risk of over exposure"],
        ["E433 - Polyoxyethylene sorbitan monooleate", "Moderate risk of over exposure"],
        ["E150a - Plain caramel", "No or very low risk of over exposure"],
        ["E252 - Potassium nitrate", "High risk of over exposure"],
        ["E220 - Sulphur dioxide", "High risk of over exposure"],
        ["E960 - Steviol glycosides", "Moderate risk of over exposure"],
        ["E132 - Indigotine", "No or very low risk of over exposure"],
        ["E951 - Aspartame", "No or very low risk of over exposure"],
        ["E150d - Sulphite ammonia caramel", "No or very low risk of over exposure"],
        ["E1520 - Propylene Glycol", "No or very low risk of over exposure"],
        ["E170i - Calcium carbonate", "No or very low risk of over exposure"],
        ["E491 - Sorbitan monostearate", "High risk of over exposure"],
        ["E492 - Sorbitan tristearate", "High risk of over exposure"],
        ["E407a - Processed eucheuma seaweed", "High risk of over exposure"],
        ["E473 - Sucrose esters of fatty acids", "High risk of over exposure"],
        ["E224 - Potassium metabisulphite", "High risk of over exposure"],
        ["E212 - Potassium benzoate", "High risk of over exposure"],
        ["E451 - Triphosphates", "High risk of over exposure"],
        ["E340 - Potassium phosphates", "High risk of over exposure"],
        ["E339 - Sodium phosphates", "High risk of over exposure"],
        ["E251 - Sodium nitrate", "High risk of over exposure"],
        ["E222 - Sodium bisulphite", "High risk of over exposure"],
        ["E131 - Patent blue v", "Moderate risk of over exposure"],
        ["E142 - Green s", "Moderate risk of over exposure"],
        ["E432 - Polyoxyethylene sorbitan monolaurate", "Moderate risk of over exposure"],
        ["E511 - Magnesium chloride", "Moderate risk of over exposure"],
        ["E507 - Hydrochloric acid", "Moderate risk of over exposure"],
        ["E436 - Polyoxyethylene sorbitan tristearate", "Moderate risk of over exposure"],
        ["E155 - Brown ht", "High risk of over exposure"],
        ["E228 - Potassium bisulphite", "High risk of over exposure"],
        ["E213 - Calcium benzoate", "High risk of over exposure"],
        ["E151 - Brilliant black bn", "No or very low risk of over exposure"],
        ["E123 - Amaranth", "No or very low risk of over exposure"],
        ["E122 - Azorubine", "No or very low risk of over exposure"],
        ["E150b - Caustic sulphite caramel", "No or very low risk of over exposure"],
        ["E509 - Calcium chloride", "Moderate risk of over exposure"],
        ["E494 - Sorbitan monooleate", "High risk of over exposure"],
        ["E493 - Sorbitan monolaurate", "High risk of over exposure"],
         ["E434 - Polyoxyethylene sorbitan monopalmitate", "Moderate risk of over exposure"],
        ["E213 - Calcium benzoate", "High risk of over exposure"],
        ["E227 - Calcium bisulphite", "High risk of over exposure"],
        ["E495 - Sorbitan monopalmitate", "High risk of over exposure"]
    ]
    
    var searchedProducts: [product] = []
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchedProducts.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let onlyOneBatch = 1
        return onlyOneBatch //1 because we only want one "batch" of movies to show at one time (the searched amount)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SearchCollectionViewCell //need declare cell as SearchCollectionViewCell to properly display movie poster and label
        cell.searchImageView.contentMode = .scaleAspectFill
        cell.searchImageView.clipsToBounds = true
        cell.searchLabel.numberOfLines = 0
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true

        let specificProduct = searchedProducts[indexPath.item]
        
        cell.searchLabel.text = specificProduct.productName
        
        // Reset the image to a placeholder or nil, to avoid showing a stale image from a reused cell.
            cell.searchImageView.image = nil

            // Check if imageUrl is not nil and then download the image
            if let imageUrlString = specificProduct.imageUrl, let url = URL(string: imageUrlString) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            cell.searchImageView.image = image
                        }
                    }
                }.resume()
            }
                
        return cell
    }
    

    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    
    
    private func fetchData(for code: String, completion: @escaping (ProductResponse) -> Void, errorHandler: @escaping (String) -> Void) {
        let urlString = "https://world.openfoodfacts.net/api/v2/product/\(code)"
        print("Searching open food facts for \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("URL construction failed.")
            errorHandler("Failed to construct URL. Please click off this tab and click back onto camera tab")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for network errors
            if let error = error {
                print("Error during URLSession data task: \(error.localizedDescription)")
                errorHandler("Error during URLSession data task: \(error.localizedDescription). Please click off this tab and click back onto camera tab")
                return
            }
            
            // Check for valid server response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Server returned an error response")
                errorHandler("Server returned an error response. This might not be a food item. Please click on any other tab, then click the camera tab again.")
                return
            }
            
            // Check for data
            guard let data = data else {
                print("No data returned from server")
                errorHandler("No data returned from server. Please click off this tab and click back onto camera tab.")
                return
            }
            
            // Attempt to decode the JSON data
            do {
                let productResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                completion(productResponse)
            } catch {
                print("Decoding JSON Error: \(error)")
                errorHandler("Decoding JSON Error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    
    func fetchImageURLString(for code: String) -> String {
        let baseURL = "https://images.openfoodfacts.org/images/products"
        let inputString = code
        // Default image URL
        let defaultImageURL = "https://t3.ftcdn.net/jpg/04/62/93/66/360_F_462936689_BpEEcxfgMuYPfTaIAOC1tCDurmsno7Sp.jpg"
        // Initialize finalURL with default image URL
        var finalURL = defaultImageURL
        
        if code.count > 8 {
            let regexPattern = "^(...)(...)(...)(.*)$"
            
            do {
                let regex = try NSRegularExpression(pattern: regexPattern, options: [])
                let range = NSRange(inputString.startIndex..<inputString.endIndex, in: inputString)
                
                if let match = regex.firstMatch(in: inputString, options: [], range: range) {
                    let group1 = (inputString as NSString).substring(with: match.range(at: 1))
                    let group2 = (inputString as NSString).substring(with: match.range(at: 2))
                    let group3 = (inputString as NSString).substring(with: match.range(at: 3))
                    let group4 = (inputString as NSString).substring(with: match.range(at: 4))
                    
                    finalURL = "\(baseURL)/\(group1)/\(group2)/\(group3)/\(group4)/1.400.jpg"
                }
            } catch {
                print("Error creating regular expression: \(error)")
            }
        } else {
            finalURL = "\(baseURL)/\(inputString)/1.400.jpg"
        }
        
        print("Product Image URL - \(finalURL)")
        
        return finalURL
    }
    
    
    

    func found(code: String) {
        print(code)
        fetchData(for: code, completion: { [weak self] productResponse in
            DispatchQueue.main.async {
                guard let self = self else { return }
                print("Fetched product response: \(productResponse)")
                
                if productResponse.status == 0 {
                    // Product not found or error in response
                    let alert = UIAlertController(title: "Not Found", message: "Product not found or unable to scan.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                    return
                }

                let detailedVC = DetailedViewController()
                // Configure detailedVC with productResponse data
                detailedVC.code = productResponse.code
                detailedVC.productName = productResponse.product.productName ?? "No name"
                detailedVC.carbsPerServing = "Carb content (g): \(productResponse.product.nutriments?.carbsPerServing?.description ?? "Data not available")"
                detailedVC.fatPerServing = "Fat content (g): \(productResponse.product.nutriments?.fatPerServing?.description ?? "Data not available")"
                detailedVC.proteinsPerServing = "Protein content (g): \(productResponse.product.nutriments?.proteinsPerServing?.description ?? "Data not available")"
                detailedVC.caloriesPerServing = "Calorie content: \(productResponse.product.nutriments?.caloriesPerServing?.description ?? "Data not available")"
                detailedVC.nutriscore = "NutriScore: \(productResponse.product.nutriscore?.uppercased() ?? "No Data") (Click to learn more)"
                detailedVC.novaGroup = "NOVA Group: \(productResponse.product.novaGroup?.description ?? "No Data") (Click to learn more)"
                var additivesString = ""
                if let calledAdditives = productResponse.product.additives{
                    print(calledAdditives)
                    let filteredAdditiveList = calledAdditives.map{ $0.replacingOccurrences(of: "en:", with: "").uppercased()}
                    
                    for additive in filteredAdditiveList{
                        if let match = self.dangerousAdditives.first(where: {$0[0].contains(additive)}){
                            let modifiedMatch = match[0].split(separator: "-").map(String.init).last?.trimmingCharacters(in: .whitespacesAndNewlines)
                            if let name = modifiedMatch {
                                additivesString.append("\n\(name)\nRisk: \(match[1])\n")
                            }
                        }
                    }
                    if additivesString.count == 0 {
                        detailedVC.additives = "Additives: No harmful additives found"
                    }
                    else{
                        detailedVC.additives = "Additives: \(additivesString)"
                
                    }
                    
                }
                

                let imageURLString = self.fetchImageURLString(for: code)
                if let imageURL = URL(string: imageURLString) {
                    self.downloadImage(from: imageURL) { image in
                        detailedVC.productImage = image ?? UIImage(named: "defaultImage")
                        detailedVC.imageUrl = imageURLString
                        print("End downloading")

                        self.navigationController?.pushViewController(detailedVC, animated: true)
                    }
                }
            }
        }, errorHandler: { [weak self] errorMessage in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let alertController = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProduct = searchedProducts[indexPath.item]
        
        let barcode = selectedProduct.code //code
        
        found(code: barcode)
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBarOutlet.text {
            // Replace all spaces in the query with plusses
            let modifiedQuery = query.replacingOccurrences(of: " ", with: "+")

            DispatchQueue.global(qos: .userInitiated).async {
                self.queryFood(query: modifiedQuery)
                DispatchQueue.main.async {
                    
                    self.collectionViewOutlet.reloadData()
                }
            }
        }
    }

    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBarOutlet.text = "" //clearing the search
    }
    
   //inspired by Lab4 - Jose Gutierrez
    func queryFood(query: String){
        // Encode the search query to be URL safe
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error encoding query")
            return
        }

        // Construct the API URL with sorting by product name
//        let urlString = "https://world.openfoodfacts.net/api/v2/search?search_terms=\(encodedQuery)&fields=product_name,code,brands,image_front_url&sort_by=product_name"
        
        let urlString = "https://world.openfoodfacts.org/cgi/search.pl?search_terms=\(query)&search_simple=1&action=process&json=1&fields=product_name,code,brands,image_front_url,nutriscore_score,energy-kcal,fat,proteins,carbohydrates,nova-group"

        print("Searching open food facts for \(query)")
        
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            return
        }
        
        // async fetching
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received.")
                return
            }
            
            do {
                // json decode
                let jsonContent = try JSONDecoder().decode(searchResponse.self, from: data)
                print("Decoded response with \(jsonContent.numResults) results.")
                
                // Update main
                DispatchQueue.main.async {
                    if jsonContent.numResults <= 30 { // so we don't have more than 30 results (as per the rubric)
                        self.searchedProducts = jsonContent.results
                    } else {
                        self.searchedProducts = Array(jsonContent.results.prefix(20))
                    }
                    
                    // Reloading collection view
                    self.collectionViewOutlet.reloadData()
                }
            } catch {
                print("JSON decoding failed: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }

    // Adjusts the spacing between lines in the grid
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }

    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: indexPath.section)
        let lineSpacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: indexPath.section)
        let insets = collectionView.contentInset
        let numberOfItemsPerRow: CGFloat = 2 // Adjust as needed
        let totalSpacing = (numberOfItemsPerRow - 1) * spacing
        let totalInset = insets.left + insets.right

        let availableWidth = collectionView.frame.width - totalSpacing - totalInset
        let widthPerItem = (availableWidth / numberOfItemsPerRow) - 10 // Reduce each cell's width by 10 points
        let heightPerItem = (widthPerItem * 1.25) - lineSpacing // Adjust height according to line spacing

        return CGSize(width: widthPerItem, height: heightPerItem)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarOutlet.delegate = self
        collectionViewOutlet.dataSource = self
        collectionViewOutlet.delegate = self

        // Do any additional setup after loading the view.
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
