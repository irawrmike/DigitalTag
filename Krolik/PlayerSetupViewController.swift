//
//  PlayerSetupViewController.swift
//  Krolik
//
//  Created by Colin Russell, Mike Cameron, and Mike Stoltman
//  Copyright © 2018 Krolik Team. All rights reserved.
//

import UIKit

class PlayerSetupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var gameIDField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    //MARK: Properties
    let networkManager = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.isEnabled = false
        playerImageView.contentMode = .scaleAspectFit
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.center = playerImageView.center
        view.addSubview(spinner)
        spinner.startAnimating()
        submitButton.isEnabled = false
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("ERROR: No image found")
            return
        }
        
        playerImageView.image = image
        
        networkManager.uploadPhoto(photo: image, path: "gameTestID/image.png") { (url, error) in
            if error != nil {
                print(error ?? "error?")
            }
            // check for a face in the image here!!
            self.networkManager.checkPhotoFace(photoURL: url.absoluteString) { (isFace) in
                
                DispatchQueue.main.async {
                    let faceAlert = UIAlertController(title: "Finished Checking Photo", message: "", preferredStyle: .alert)
                    faceAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

                    if isFace {
                        self.submitButton.isEnabled = true
                        faceAlert.message = "Face was found. If ready to start, hit the submit button!"
                        self.present(faceAlert, animated: true, completion: nil)
                    } else {
                        faceAlert.message = "Face was NOT found. Please take picture of your face again!"
                        self.present(faceAlert, animated: true, completion: nil)
                    }
                    spinner.stopAnimating()
                    
                }
            }
        }
        
    }
    
    
    //MARK: Actions
    
    @IBAction func takeANewPhotoButtonPressed(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.cameraDevice = .front
        imagePicker.cameraFlashMode = .off
        
        // Create the Camera Overlay
        let overlayOrigin = CGPoint(x: view.frame.origin.x+75, y: view.frame.origin.y+15)
        let overlaySize = CGSize(width: view.frame.width-150, height: view.frame.height-150)
        let cameraOverlay = UIImageView(frame: CGRect(origin: overlayOrigin, size: overlaySize))
        cameraOverlay.image = UIImage(named: "faceOutline")
        cameraOverlay.contentMode = .scaleAspectFit
        imagePicker.cameraOverlayView = cameraOverlay
        
        present(imagePicker, animated: true)
        
        // Hide/Show the camera overlay
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "_UIImagePickerControllerUserDidCaptureItem"), object:nil, queue:nil, using: { note in
            imagePicker.cameraOverlayView = nil
        })
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "_UIImagePickerControllerUserDidRejectItem"), object:nil, queue:nil, using: { note in
            imagePicker.cameraOverlayView = cameraOverlay
        })
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        
    }
    
    
}


