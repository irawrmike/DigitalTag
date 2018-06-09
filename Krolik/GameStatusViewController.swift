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
    
    let networkManager = NetworkManager()
    var currentGame: Game?
    var currentPlayers: [Player] = []
    let database = DatabaseManager()
    let game = GameLogic()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        database.read(gameID: UserDefaults.standard.string(forKey: Game.keys.id)!) { (game) in
            guard let game = game else {
                print("game read returned nil value")
                return
            }
            self.currentGame = game
            self.checkGameState()
            
            let players = Array(game.players.keys)
            
            self.currentPlayers = []
            
            for player in players {
                self.database.read(playerID: player, completion: { (player) in
                    self.currentPlayers.append(player!)
                    self.collectionView.reloadData()
                })
            }
        }
    }
    
    //MARK: UICollectionViewMethods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentPlayers.count
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
 
        let player = currentPlayers[indexPath.row]
        
        networkManager.getDataFromUrl(url: URL(string: player.photoURL)!) { (data, response, error) in
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
        
        let headerButton = header.viewWithTag(1) as! UIButton
        let gameNameLabel = header.viewWithTag(2) as! UILabel
        let gameIDLabel = header.viewWithTag(3) as! UILabel
        
        checkGameState(button: headerButton)
        
        gameNameLabel.text = "Game: \(currentGame?.name ?? "")"
        gameIDLabel.text = "ID: \(currentGame?.id ?? "")"
        
        return header
    }
    
    //MARK: Actions
    
    @IBAction func headerButtonTapped(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else {return}
        
        if title == "Start Game" {
            print("start game button tapped")
            if currentGame?.players.count == 1 {
                sender.isEnabled = true
                let singlePlayerAlert = UIAlertController(title: "", message: "Comrade, please recruit more civilians for cause, or end game.", preferredStyle: .alert)
                singlePlayerAlert.addAction(UIAlertAction(title: "Quit", style: .default, handler: { (_) in
                    // get game id from user defaults before deletion
                    let gameID = UserDefaults.standard.string(forKey: Game.keys.id)
                    let playerID = UserDefaults.standard.string(forKey: Player.keys.id)
                    // remove game from user defaults
                    UserDefaults.standard.removeObject(forKey: Game.keys.id)
                    UserDefaults.standard.removeObject(forKey: Player.keys.id)
                    // segue to root view controller
                    self.performSegue(withIdentifier: "quitGameSegue", sender: self)
                    // delete game/player
                    self.database.databaseRef.child(Game.keys.root).child(gameID!).removeValue()
                    self.database.databaseRef.child(Player.keys.root).child(playerID!).removeValue()
                }))
                singlePlayerAlert.addAction(UIAlertAction(title: "Recruit", style: .default, handler: nil))
                present(singlePlayerAlert, animated: true, completion: nil)
            }else{
                game.currentGame = currentGame
                game.startGame()
                sender.isEnabled = false
            }
        }else if title == "Quit Game" {
            // remove player from game then players list
            let gameID = UserDefaults.standard.string(forKey: Game.keys.id)
            let playerID = UserDefaults.standard.string(forKey: Player.keys.id)
            database.databaseRef.child(Game.keys.root).child(gameID!).child(Game.keys.players).child(playerID!).removeValue { (_, _) in
                self.database.databaseRef.child(Player.keys.root).child(playerID!).removeValue()
            }
            // remove game/player from user defaults
            UserDefaults.standard.removeObject(forKey: Game.keys.id)
            UserDefaults.standard.removeObject(forKey: Player.keys.id)
            // segue to root view controller
            self.performSegue(withIdentifier: "quitGameSegue", sender: self)
        }
    }
    
    //MARK: Game Status
    
    func checkGameState(button: UIButton? = nil) {
        if currentGame?.state == Game.state.pending {
            if let tabBarItems = self.tabBarController?.tabBar.items as AnyObject as? NSArray,let tabBarItem = tabBarItems[1] as? UITabBarItem {
                tabBarItem.isEnabled = false
            }
            if let headerButton = button {
                if UserDefaults.standard.bool(forKey: Player.keys.owner) {
                    headerButton.titleLabel?.text = "Start Game"
                    headerButton.isHidden = false
                }else{
                    headerButton.titleLabel?.text = "Quit Game"
                    headerButton.isHidden = false
                }
            }
        }else if currentGame?.state == Game.state.active {
            if let tabBarItems = self.tabBarController?.tabBar.items as AnyObject as? NSArray,let tabBarItem = tabBarItems[1] as? UITabBarItem {
                tabBarItem.isEnabled = true
            }
            if let headerButton = button {
                headerButton.isHidden = true
            }
        }else if currentGame?.state == Game.state.ended {
            if let tabBarItems = self.tabBarController?.tabBar.items as AnyObject as? NSArray,let tabBarItem = tabBarItems[1] as? UITabBarItem {
                tabBarItem.isEnabled = false
                performSegue(withIdentifier: "quitFromStatus", sender: self)
            }
            if let headerButton = button {
                headerButton.isHidden = true
            }
        }
    }
    
}
