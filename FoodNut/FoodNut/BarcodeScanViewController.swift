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
    
    
    private enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case nutriments = "nutriments"
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
    var caloires: Int
    var fat: Int
    var carbs: Int
    var protein: Int
}

class BarcodeScanView: UIViewController {
    
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
                let detailedVC = DetailedViewController()
                detailedVC.code = productResponse.code
                detailedVC.productName = productResponse.product.productName
                detailedVC.caloriesPerServing = "Calorie content: \(productResponse.product.nutriments?.caloriesPerServing.map { "\($0) calories" } ?? "Data not available")"
                detailedVC.fatPerServing = "Fat content: \(productResponse.product.nutriments?.fatPerServing.map { "\($0)g" } ?? "Data not available")"
                detailedVC.proteinsPerServing = "Protein content: \(productResponse.product.nutriments?.proteinsPerServing.map { "\($0)g" } ?? "Data not available")"
                detailedVC.carbsPerServing = "Carb content: \(productResponse.product.nutriments?.carbsPerServing.map { "\($0)g" } ?? "Data not available")"
                
                let imageURLString = self.fetchImageURLString(for: code)
                if let imageURL = URL(string: imageURLString) {
                    self.downloadImage(from: imageURL) { image in
                    detailedVC.productImage = image
                    print("end downloading")
                    print(image!)
                        
                    self.navigationController?.pushViewController(detailedVC, animated: true)
                    }
                }
            }
        }
        
    }
    
    private func fetchData(for code: String, completion: @escaping (ProductResponse) -> Void) {
        let urlString = "https://world.openfoodfacts.net/api/v2/product/\(code)?fields=product_name,nutriscore_data,nutriments,nutrition_grades"
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
        var finalURL = ""
        
        if (code.count > 8) {
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
            finalURL = baseURL + "/" + inputString + "1.400.jpg"
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
