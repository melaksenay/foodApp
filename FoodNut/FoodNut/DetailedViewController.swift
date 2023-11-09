//
//  DetailedViewController.swift
//  FoodNut
//
//  Created by Mitchell vom Scheidt on 11/8/23.
//

import UIKit

class DetailedViewController: UIViewController {
    var code: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        let codeDisplayLabelFrame = CGRect(x: view.frame.midX - 100, y: 525, width: 200, height: 30)
        let codeDisplayLabel = UILabel(frame: codeDisplayLabelFrame)
        codeDisplayLabel.font = codeDisplayLabel.font.withSize(20)
        view.addSubview(codeDisplayLabel)
            
        if let code = code {
            codeDisplayLabel.text = code
        }
    }
    
    
}
