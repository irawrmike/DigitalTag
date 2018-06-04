//
//  GameStatusViewController.swift
//  Krolik
//
//  Created by Colin Russell, Mike Cameron, and Mike Stoltman
//  Copyright © 2018 Krolik Team. All rights reserved.
//

import UIKit
import FirebaseStorage

class GameStatusViewController: UIViewController, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UICollectionViewMethods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playerCell", for: indexPath)
        cell.contentView.layer.borderWidth = 2
        cell.contentView.layer.cornerRadius = 15
        cell.contentView.layer.borderColor = UIColor.black.cgColor
        cell.layer.masksToBounds = true
        
        let cellFrame = cell.contentView.frame
        let imageFrame = CGRect(x: cellFrame.origin.x+10, y: cellFrame.origin.y+10, width: cellFrame.width-20, height: cellFrame.height-20)
        let imageView = UIImageView(frame: imageFrame)
        imageView.contentMode = .scaleAspectFit
 
        getDataFromUrl(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/krolik-9ed87.appspot.com/o/gameTestID%2Fimage.png?alt=media&token=122898dd-cc3a-451d-9101-8a3843c0d949")!) { (data, response, error) in
            guard let imageData = data else {
                print("bad data")
                return
            }
            guard let image = UIImage(data: imageData) else {
                print("error creating image from data")
                return
            }
            DispatchQueue.main.async {
                imageView.image = image
                self.collectionView.cellForItem(at: indexPath)?.contentView.addSubview(imageView)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "gameLobbyHeader", for: indexPath)
        return header
    }
    
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    //MARK: Actions
    
    @IBAction func startGameButtonTapped(_ sender: UIButton) {
        print("start game button tapped")
    }
    
}
