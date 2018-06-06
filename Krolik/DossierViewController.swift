//
//  DossierViewController.swift
//  Krolik
//
//  Created by Colin on 2018-06-06.
//  Copyright © 2018 Mike Stoltman. All rights reserved.
//

import UIKit

class DossierViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK: Properties
    
    let networkManager = NetworkManager()
    let database = DatabaseManager()
    var currentGame: Game!
    var currentPlayer: Player!
    var playerTarget: Player!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePlayerAndTarget()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        
        // add spinner to imageView here
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("ERROR: No image found (DossierViewController)")
            return
        }
        
        networkManager.uploadPhoto(photo: image, path: "\(currentGame.id)/\(currentPlayer.id)_target.jpg") { (url, error) in
            if error != nil {
                print(error ?? "error uploading photo in DossierViewController")
            }
            
            self.networkManager.compareFaces(target: self.playerTarget, photoURL: url.absoluteString, completion: { (isAMatch) in
                DispatchQueue.main.async {
                    if isAMatch {
                        self.killPerson()
                    } else {
                        
                    }
                }
                
            })
            
        }
    }
    
    func killPerson() {
        
        
        updatePlayerAndTarget()
    }
    
    func shootPerson() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.cameraFlashMode = .auto
        
        // add crosshair camera overlay here
        
        present(imagePicker, animated: true)
    }
    
    func updatePlayerAndTarget() {
        // get the current player and its target from the database
        database.read(playerID: UserDefaults.standard.string(forKey: Player.keys.id)!) { (currentPlayer) in
            self.currentPlayer = currentPlayer
            
            self.database.read(playerID: currentPlayer!.target!, completion: { (playerTarget) in
                self.playerTarget = playerTarget
            })
        }
    }
}
