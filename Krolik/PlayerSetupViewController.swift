//
//  PlayerSetupViewController.swift
//  Krolik
//
//  Created by Colin Russell, Mike Cameron, and Mike Stoltman
//  Copyright © 2018 Krolik Team. All rights reserved.
//

import UIKit

class PlayerSetupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    
    //MARK: Properties
    let networkManager = NetworkManager()
    let database = DatabaseManager()
    var currentGame: Game!
    var keyboardHeight: CGFloat = 0
    var currentPlayer: Player?
    var isGameOwner = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.isEnabled = false
        playerImageView.contentMode = .scaleAspectFit
        
        currentPlayer = database.createPlayer(gameID: currentGame.id)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.center = playerImageView.center
        view.addSubview(spinner)
        spinner.startAnimating()
        submitButton.isEnabled = false
        guard var image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("ERROR: No image found")
            return
        }
        
        image = image.cropsToSquare()
        image = image.makeSmaller()
        
        playerImageView.image = image
        let gameID = currentGame?.id ?? ""
        let playerID = currentPlayer?.id ?? ""
        
        networkManager.uploadPhoto(photo: playerImageView.image!, path: "\(gameID)/\(playerID).jpg") { (url, error) in
            if error != nil {
                print(error ?? "error?")
            }
            // check for a face in the image here!!
            
            
            self.networkManager.checkPhotoFace(photoURL: url.absoluteString) { [weak self] (isFace, multipleFaces) in
                DispatchQueue.main.async {
                    let faceAlert = UIAlertController(title: "Krolik Face Analysis Complete", message: "", preferredStyle: .alert)
                    
                    if isFace && multipleFaces == false {
                        faceAlert.message = "Ah, nice to see you again, comrade. If ready to start, hit the submit button."
                        faceAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self?.present(faceAlert, animated: true, completion: nil)
                        self?.currentPlayer?.photoURL = url.absoluteString
                        self?.networkManager.enrollFace(player: (self?.currentPlayer)!) { (isEnrolled) in
                            DispatchQueue.main.async {
                                if isEnrolled {
                                    self?.submitButton.isEnabled = true
                                    spinner.stopAnimating()
                                } else {
                                    print("ERROR ENROLLING face to Kairos")
                                }
                            }
                        }
                    } else {
                        faceAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                            self?.showCamera()
                        }))
                        if multipleFaces == true {
                            faceAlert.message = "Pardon, comrade. We need to see your face and your face only. Please take a picture of just you!"
                        } else {
                            faceAlert.message = "Pardon, comrade.  We need to see your beautiful face. Please try again!"
                        }
                        self?.present(faceAlert, animated: true, completion: nil)
                        spinner.stopAnimating()
                    }
                    
                    let update = [Player.keys.photo : url.absoluteString]
                    self?.database.update(playerID: (self?.currentPlayer?.id)!, update: update)
                }
            }
        }
        
    }
    
    func showCamera() {
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
    
    //MARK: Actions
    
    @IBAction func takeANewPhotoButtonPressed(_ sender: UIButton) {
        showCamera()
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        guard let player = self.currentPlayer else {return}
        database.changePlayerState(gameID: currentGame.id, playerID: player.id, state: Player.state.alive)
    }
    
    //MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "submitPlayerSegue" {
            let tab = segue.destination as? UITabBarController
            let destination = tab?.viewControllers![0] as? GameStatusViewController
            destination?.currentGame = currentGame
            UserDefaults.standard.set(currentPlayer?.id, forKey: Player.keys.id)
            UserDefaults.standard.set(currentGame.id, forKey: Game.keys.id)
        }
    }
    
}

extension UIImage {
    func makeSmaller() -> UIImage {
        let horizontalRatio = 200 / size.width
        let verticalRatio = 200 / size.height
        
        let imageRatio = max(horizontalRatio, verticalRatio) // keep original aspect ratio
        let newSize = CGSize(width: size.width * imageRatio, height: size.height * imageRatio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func cropsToSquare() -> UIImage {
        let refWidth = CGFloat((self.cgImage!.width))
        let refHeight = CGFloat((self.cgImage!.height))
        let cropSize = refWidth > refHeight ? refHeight : refWidth
        
        let x = (refWidth - cropSize) / 2.0
        let y = (refHeight - cropSize) / 2.0
        
        let cropRect = CGRect(x: x, y: y, width: cropSize, height: cropSize)
        let imageRef = self.cgImage?.cropping(to: cropRect)
        let cropped = UIImage(cgImage: imageRef!, scale: 0.0, orientation: self.imageOrientation)
        
        return cropped
    }
}
