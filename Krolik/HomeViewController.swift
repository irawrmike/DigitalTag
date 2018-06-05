//
//  HomeViewController.swift
//  Krolik
//
//  Created by Colin Russell, Mike Cameron, and Mike Stoltman
//  Copyright © 2018 Krolik Team. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITextFieldDelegate, DatabaseDelegate {
    
    //MARK: Outlets
    
    @IBOutlet weak var joinGameButton: UIButton!
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var gameIDField: UITextField!
    
    //MARK: Properties
    
    var keyboardHeight: CGFloat = 0
    var keyboardIsHidden = true
    let database = DatabaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameIDField.delegate = self
        database.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.string(forKey: Game.keys.id) != nil {
            performSegue(withIdentifier: "gameInProgress", sender: nil)
        }
    }
    
    //MARK: Keyboard Move View
    
    @objc func keyboardWillShow(notification: NSNotification) {
        // get initial keyboard height
        if keyboardHeight == 0 {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                keyboardHeight = keyboardSize.height
            }
        }
        if keyboardIsHidden {
            view.frame.origin.y -= keyboardHeight
            keyboardIsHidden = false
        }
    }
    
    @objc func keyboardWillHide() {
        view.frame.origin.y += keyboardHeight
        keyboardIsHidden = true
    }
    
    //MARK: DatabaseDelegate
    
    func readGame(game: Game?) {
        if game != nil {
            print("GAME EXISTS")
        } else {
            print("GAME DOES NOT EXIST")
        }
    }
    
    func readPlayer(player: Player?) {
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        gameIDField.resignFirstResponder()
        // do a check here to see if gameID entered exists on database
        return true
    }
    
    //MARK: Actions
    
    @IBAction func joinButtonTapped(_ sender: UIButton) {
        guard let gameID = gameIDField.text else { return }
        database.read(gameID: gameID)
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        
    }
}
