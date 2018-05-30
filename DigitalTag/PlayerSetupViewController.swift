//
//  PlayerSetupViewController.swift
//  DigitalTag
//
//  Created by Colin on 2018-05-30.
//  Copyright © 2018 Mike Stoltman. All rights reserved.
//

import UIKit

class PlayerSetupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var playerImageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            print("ERROR: No image found")
            return
        }
        
        playerImageView.image = image
        
    }
    
    
    //MARK: Actions
    
    @IBAction func takeANewPhotoButtonPressed(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.cameraDevice = .front
        
        present(imagePicker, animated: true)
    }
    
}


