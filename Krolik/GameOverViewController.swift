//
//  GameOverViewController.swift
//  Krolik
//
//  Created by Mike Stoltman on 2018-06-08.
//  Copyright © 2018 Mike Stoltman. All rights reserved.
//

import UIKit

class GameOverViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    
    let database = DatabaseManager()
    let networkManager = NetworkManager()
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.layer.borderWidth = 4
        backgroundView.layer.borderColor = UIColor.black.cgColor
        backgroundView.layer.cornerRadius = 10
        
        database.readOnce(gameID: UserDefaults.standard.string(forKey: Game.keys.id)!) { [weak self] (game) in
            guard let gameName = game?.name else {
                print("error, no game name")
                return
            }
            guard let winner = game?.winner else {
                print("error, no game winner")
                return
            }
            let winnerArray = Array(winner.keys)
            let winnerID = winnerArray[0]
            
            guard let winnerName = winner[winnerID] else {
                print("error, could not get name from winner")
                return
            }
            
            DispatchQueue.main.async {
                self?.gameNameLabel.text = gameName
                self?.nicknameLabel.text = winnerName
            }
            
            self?.database.read(playerID: winnerID, completion: { [weak self] (player) in
                guard let imageURL = player?.photoURL else {
                    print("error, could not get photoURL for winner")
                    return
                }
                self?.networkManager.getDataFromUrl(url: URL(string: imageURL)!) { (data, response, error) in
                    print("finished getting image data")
                    
                    guard let imageData = data else {
                        print("bad data")
                        return
                    }
                    guard let image = UIImage(data: imageData) else {
                        print("error creating image from data")
                        return
                    }
                    DispatchQueue.main.async {
                        print("changes image to downloaded image")
                        self?.imageView.image = image
                    }
                }
            })
            
        }
        
    }

    @IBAction func quitButtonTapped() {
        // remove user defaults and send user back to home view controller
        UserDefaults.standard.removeObject(forKey: Game.keys.id)
        UserDefaults.standard.removeObject(forKey: Player.keys.id)
        UserDefaults.standard.removeObject(forKey: Player.keys.owner)
    }
    
}
