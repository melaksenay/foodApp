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
class BarcodeScanView: UIViewController {
    
    var avCaptureSession: AVCaptureSession!
    var avPreviewLayer: AVCaptureVideoPreviewLayer!
    

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
    
    func search(code: String) {
        let urlString = "https://world.openfoodfacts.net/api/v2/product/\(code)?fields=product_name,nutriscore_data,nutriments,nutrition_grades"
        print("Searching open food facts for \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Url does not work.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            //Check for valid server response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                print("No Data. Try Scanning its Nutrition Facts. You could also have an unstable network.")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                   print("Raw JSON response: \(jsonString)")
               }
            
            // Decode the JSON data
            do {
                let productResponse = try JSONDecoder().decode(ProductResponse.self, from: data)
                print("Made an API Call and the code is: \(productResponse.code)")
                if productResponse.status == 0 {
                    print("Unable to find this item in database, try scanning its Nutrition Facts!")
                }
                else {
                    print("Also wondering what the name is: \(productResponse.product.productName )")
                    print("More information: calorie content: \(productResponse.product.nutriments?.caloriesPerServing.map { "\($0) calories" } ?? "This data is not available")")
                    print("More information: fat content: \(productResponse.product.nutriments?.fatPerServing.map { "\($0)g" } ?? "This data is not available")")
                    print("More information: protein content: \(productResponse.product.nutriments?.proteinsPerServing.map { "\($0)g" } ?? "This data is not available")")
                    print("More information: carb content: \(productResponse.product.nutriments?.carbsPerServing.map { "\($0)g" } ?? "This data is not available")")

                }
            }
                catch {
                    print("Decoding JSON Error: \(error)")
            }
        }
        

        task.resume()
    }
    
    func found(code: String) {
        print(code)
        search(code: code)
        let detailedVC = DetailedViewController()
        detailedVC.code = code
        navigationController?.pushViewController(detailedVC, animated: true)
    }
}
