//
//  BarcodeScanViewController.swift
//  FoodNut
//
//  Created by Mitchell vom Scheidt on 11/8/23.
//

// SOURCE: https://www.wepstech.com/bar-qr-code-ios-with-swift-5/

import UIKit
import AVFoundation


struct ProductResponse: Decodable {
    var code: String
    var status: Int
    var product: Product
}

struct Product: Decodable {
    var productName: String
    var nutriments: NutritionFacts?
    var imageURL : String
    var nutriscore: String
    var catHierarchy: [String]
    var novaGroup: Double?
    var ingredients: String?
    var additives: [String]?
    
    private enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case nutriments = "nutriments"
        case imageURL = "image_url"
        case nutriscore = "nutriscore_grade"
        case catHierarchy = "categories_hierarchy"
        case novaGroup = "nova_group"
        case ingredients = "ingredients_text_en"
        case additives = "additives_tags"
    }
}

struct NutritionFacts: Decodable {
    var carbsPerServing: Double?
    var fatPerServing: Double?
    var proteinsPerServing: Double?
    var caloriesPerServing: Double?
    
    private enum CodingKeys: String, CodingKey {
        case carbsPerServing = "carbohydrates_serving"
        case fatPerServing = "fat_serving"
        case proteinsPerServing = "proteins_serving"
        case caloriesPerServing = "energy-kcal_serving"
    }
}

struct productStorage: Codable, Hashable {
    var name: String
    var id: String
    var imageURL: String
    var score: String
    var calories: String
    var fat: String
    var carbs: String
    var protein: String
    var hierarchy: [String]
}

class BarcodeScanView: UIViewController {
    
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
    
    var avCaptureSession: AVCaptureSession!
    var avPreviewLayer: AVCaptureVideoPreviewLayer!
    var barcode:String = ""
    var carbs:String = ""
    var fat:String = ""
    var proteins:String = ""
    var cals:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avCaptureSession = AVCaptureSession()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                self.failed()
                return
            }
            let avVideoInput: AVCaptureDeviceInput
            
            do {
                avVideoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                self.failed()
                return
            }
            
            if (self.avCaptureSession.canAddInput(avVideoInput)) {
                self.avCaptureSession.addInput(avVideoInput)
            } else {
                self.failed()
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if (self.avCaptureSession.canAddOutput(metadataOutput)) {
                self.avCaptureSession.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr]
            } else {
                self.failed()
                return
            }
            
            self.avPreviewLayer = AVCaptureVideoPreviewLayer(session: self.avCaptureSession)
            self.avPreviewLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 100)
            self.avPreviewLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(self.avPreviewLayer)
            //background thread for UI responsiveness.
            DispatchQueue.global(qos:.background).async {
                self.avCaptureSession.startRunning()
            }
        }
    }
    
    
    func failed() {
        let ac = UIAlertController(title: "Scanner not supported", message: "Please use a device with a camera. Because this device does not support scanning a code", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        avCaptureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (avCaptureSession?.isRunning == false) {
            //background thread for UI responsiveness.
            DispatchQueue.global(qos:.background).async {
                self.avCaptureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (avCaptureSession?.isRunning == true) {
            avCaptureSession.stopRunning()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}
extension BarcodeScanView : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        avCaptureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        dismiss(animated: true)
    }
    
    func found(code: String) {
        print(code)
    
        fetchData(for: code) { [weak self] productResponse in
            DispatchQueue.main.async {
                guard let self = self else { return }
                print("Fetched product response: \(productResponse)")
                
                if(productResponse.status == 1){
                    let newProduct = productStorage(
                        
                        name: productResponse.product.productName, id: productResponse.code,
                        
                        imageURL: productResponse.product.imageURL,
                        
                        score: productResponse.product.nutriscore,
                        
                        calories: "\(productResponse.product.nutriments?.caloriesPerServing.map { "\($0) calories" } ?? "Data not available")",
                        
                        fat: "\(productResponse.product.nutriments?.fatPerServing.map { "\($0)g" } ?? "Data not available")",
                        
                        carbs: "\(productResponse.product.nutriments?.carbsPerServing.map { "\($0)g" } ?? "Data not available")",
                        
                        protein: "\(productResponse.product.nutriments?.proteinsPerServing.map { "\($0)g" } ?? "Data not available")" ,
                        
                        hierarchy: productResponse.product.catHierarchy
                        
                    )
                    
                    self.saveProductToUserDefaults(newProduct)
                }
                else{
                    print("Could not be found")
                }
                
                if let firstCategory = productResponse.product.catHierarchy.first {
                    self.updateCategoryScanCount(for: firstCategory)
                                }
              
                //Fill out detailed View Controller
                let detailedVC = DetailedViewController()
    
                
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
                    
                } else{
                    detailedVC.additives = "No Data/No harmful additives found"
                }
                    
                    
               
                            
                
                
                detailedVC.nutriscore = "NutriScore: \(productResponse.product.nutriscore.uppercased())" // fix this.
                detailedVC.code = productResponse.code
                detailedVC.productName = productResponse.product.productName
                detailedVC.caloriesPerServing = "Calorie content: \(productResponse.product.nutriments?.caloriesPerServing.map { "\($0) calories" } ?? "Data not available")"
                detailedVC.fatPerServing = "Fat content: \(productResponse.product.nutriments?.fatPerServing.map { "\($0)g" } ?? "Data not available")"
                detailedVC.proteinsPerServing = "Protein content: \(productResponse.product.nutriments?.proteinsPerServing.map { "\($0)g" } ?? "Data not available")"
                detailedVC.carbsPerServing = "Carb content: \(productResponse.product.nutriments?.carbsPerServing.map { "\($0)g" } ?? "Data not available")"
                if let novaGroup = productResponse.product.novaGroup {
                    detailedVC.novaGroup = "Nova Group: \(novaGroup)"
                } else {
                    detailedVC.novaGroup = "No Data"
                }
                if let ingredients = productResponse.product.ingredients{
                    detailedVC.ingredients = "Ingredients to watch: \(ingredients)"
                } else{
                    detailedVC.ingredients = "No Data"
                }
                
                let imageURLString = self.fetchImageURLString(for: code)
                
                if let imageURL = URL(string: imageURLString) {
                    self.downloadImage(from: imageURL) { image in
                    detailedVC.productImage = image ?? UIImage (named: "defaultImage")
                    detailedVC.imageUrl = imageURLString
                    print("end downloading")
                    print(image!)
                        
                    self.navigationController?.pushViewController(detailedVC, animated: true)
                    }
                }
            }
        }
        
    }
    
    // Function to update category scan count
        func updateCategoryScanCount(for category: String) {
            var categoryScans = fetchCategoryScansFromUserDefaults()
            categoryScans[category, default: 0] += 1
            saveCategoryScansToUserDefaults(categoryScans)
        }

        // Function to fetch category scans from UserDefaults
        func fetchCategoryScansFromUserDefaults() -> [String: Int] {
            let defaults = UserDefaults.standard
            if let savedScans = defaults.object(forKey: "categoryScans") as? Data {
                if let decodedScans = try? JSONDecoder().decode([String: Int].self, from: savedScans) {
                    return decodedScans
                }
            }
            return [:]
        }

        // Function to save category scans to UserDefaults
        func saveCategoryScansToUserDefaults(_ scans: [String: Int]) {
            let defaults = UserDefaults.standard
            if let encoded = try? JSONEncoder().encode(scans) {
                defaults.set(encoded, forKey: "categoryScans")
            }
        }
    
    // Function to save a product to UserDefaults
    func saveProductToUserDefaults(_ product: productStorage) {
        let defaults = UserDefaults.standard
        var products = fetchProductsFromUserDefaults()

        // Adding the new product at the beginning of the list
        products.insert(product, at: 0)

        // Ensuring the list doesn't exceed 3 items
        if products.count > 3 {
            products.removeLast()
        }

        // Saving the updated list to UserDefaults
        if let encoded = try? JSONEncoder().encode(products) {
            defaults.set(encoded, forKey: "savedProducts")
        }
    }

    // Function to fetch products from UserDefaults
    func fetchProductsFromUserDefaults() -> [productStorage] {
        let defaults = UserDefaults.standard
        if let savedProducts = defaults.object(forKey: "savedProducts") as? Data {
            if let decodedProducts = try? JSONDecoder().decode([productStorage].self, from: savedProducts) {
                return decodedProducts
            }
        }
        return []
    }
    
    private func fetchData(for code: String, completion: @escaping (ProductResponse) -> Void) {
        let urlString = "https://world.openfoodfacts.net/api/v2/product/\(code)"
        print("Searching open food facts for \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("URL construction failed.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error during URLSession data task: \(error.localizedDescription)")
                return
            }
            
            // Check for valid server response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Server returned an error response")
                return
            }
            
            // Check for data
            guard let data = data else {
                print("No data returned from server")
                return
            }
            
            // Decode the JSON data
            do {
                let productResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                completion(productResponse)
                print(productResponse.product.nutriments?.caloriesPerServing ?? "no cals")
            } catch {
                print("Decoding JSON Error: \(error)")
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
    
}
