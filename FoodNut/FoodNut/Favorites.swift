//
//  Favorites.swift
//  FoodNut
//
//  Created by Logan Farrow on 12/2/23.
//

import UIKit

class Favorites: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    
    

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self

        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "scanCell", for: indexPath) as! FavoritesCell
        
        cell.favoriteLabel.layer.cornerRadius = cell.favoriteLabel.frame.size.width / 18
        cell.favoriteLabel.clipsToBounds = true
        
        
        
        
        return cell
        
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //items per section in collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    


}
