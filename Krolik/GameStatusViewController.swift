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
    var currentPlayer: Player!
    let database = DatabaseManager()
    let game = GameLogic()
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.tintColor = UIColor.darkGray
        collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "corktexture")!)
        
        database.read(gameID: UserDefaults.standard.string(forKey: Game.keys.id)!) { (game) in
            guard let game = game else {
                print("game read returned nil value")
                return
            }
            self.currentGame = game
            
            self.checkGameState()
            
            let players = Array(game.players.keys)
            
            self.currentPlayers = []
            
            for plyr in players {
                self.database.read(playerID: plyr, completion: { (player) in
                    self.currentPlayers.append(player!)
                    
                    if plyr == UserDefaults.standard.string(forKey: Player.keys.id) {
                        self.currentPlayer = player!
                    }
                    
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

        cell.layer.masksToBounds = true
        
        let cellFrame = cell.contentView.frame
        let imageFrame = CGRect(x: cellFrame.origin.x+10, y: cellFrame.origin.y+5, width: cellFrame.width-20, height: cellFrame.height-30)
        let imageView = UIImageView(frame: imageFrame)
        imageView.contentMode = .scaleAspectFit
        
        let player = currentPlayers[indexPath.row]
        guard let playerState = currentGame?.players[player.id] else { return  cell }
        
        
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
                
                let overlayOrigin = cell.contentView.frame.origin
                let overlaySize = cell.contentView.frame.size
                
                // if player dies add X overlay
                let deadOverlay = UIImageView(frame: CGRect(origin: overlayOrigin, size: overlaySize))
                deadOverlay.image = UIImage(named: "deadX")
                deadOverlay.contentMode = .scaleAspectFit
                if  playerState == Player.state.dead {
                    cell.contentView.insertSubview(deadOverlay, aboveSubview: imageView)
                    deadOverlay.isHidden = false
                } else {
                    deadOverlay.isHidden = true
                }
                
                // Create the target Overlay
                let targetOverlay = UIImageView(frame: CGRect(origin: overlayOrigin, size: overlaySize))
                targetOverlay.image = UIImage(named: "targetCircle")
                targetOverlay.contentMode = .scaleAspectFit
                // add overlay to cell for the current player's target
                if self.currentGame?.state == Game.state.active {
                    if self.currentPlayers[indexPath.row].id == self.currentPlayer.target {
                        cell.contentView.insertSubview(targetOverlay, aboveSubview: imageView)
                        targetOverlay.isHidden = false
                    }
                    else {
                        targetOverlay.isHidden = true
                    }
                }
                
                // create/add pushpin to cell
                let pushpinView = UIImageView(image: UIImage(named: "pushpin"))
                let centerX = (cell.contentView.frame.size.width / 2) - 5
                cell.contentView.insertSubview(pushpinView, aboveSubview: targetOverlay)
                pushpinView.frame.origin.x = centerX
            }
        }
        
        // rotate cell by random amount up to 20 degrees
        let rotate = collectionView.layoutAttributesForItem(at: indexPath)?.transform.rotated(by: randomRotation())
        cell.transform = rotate!
        
        cell.backgroundColor = UIColor.white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "gameLobbyHeader", for: indexPath)
        
        let gameNameLabel = header.viewWithTag(2) as! UILabel
//        let gameIDLabel = header.viewWithTag(3) as! UILabel
        
        gameNameLabel.text = currentGame?.name ?? ""
//        gameIDLabel.text = "ID: \(currentGame?.id ?? "")"
        
        header.backgroundColor = UIColor.white
        
        if let currentGame = currentGame {
            if currentGame.state == Game.state.pending {
                if let headerButton = header.viewWithTag(1) as? UIButton {
                    if UserDefaults.standard.bool(forKey: Player.keys.owner) {
                        headerButton.setTitle("Start Game", for: .normal)
                        headerButton.isHidden = false
                    }else{
                        headerButton.setTitle("Quit Game", for: .normal)
                        headerButton.isHidden = false
                    }
                }
                if let inviteButton = header.viewWithTag(4) as? UIButton {
                    inviteButton.isHidden = false
                }
            }else if currentGame.state == Game.state.active {
                if let headerButton = header.viewWithTag(1) as? UIButton {
                    headerButton.isHidden = true
                }
                if let inviteButton = header.viewWithTag(4) as? UIButton {
                    inviteButton.isHidden = true
                }
            }else if currentGame.state == Game.state.ended {
                if let headerButton = header.viewWithTag(1) as? UIButton {
                    headerButton.isHidden = true
                }
                if let inviteButton = header.viewWithTag(4) as? UIButton {
                    inviteButton.isHidden = true
                }
            }
        }
        return header
    }
    
    func randomRotation() -> CGFloat {
        // get random degrees value
        var random = Double(arc4random_uniform(20))
        // convert to negative by random
        if arc4random_uniform(2) == 0 {
            random = random * -1
        }
        // convert to radians for rotation
        let radians = convertToRadians(value: random)
        return radians
    }
    
    func convertToRadians(value: Double) -> CGFloat {
        let degrees = value
        let radians = degrees * (Double.pi / 180)
        let converted = CGFloat(radians)
        return converted
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
                singlePlayerAlert.addAction(UIAlertAction(title: "Recruit", style: .default, handler: { (_) in
                    let textToShare = "Comrade, join fight from link if dare."
                    
                    if let gameID = self.currentGame?.id {
                        if let krolikURL = NSURL(string: "krolik://\(gameID)") {
                            let objectsToShare = [textToShare, krolikURL] as [Any]
                            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                            
                            activityVC.popoverPresentationController?.sourceView = sender
                            self.present(activityVC, animated: true, completion: nil)
                        }
                    }
                }))
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
    
    @IBAction func inviteButtonTapped(_ sender: UIButton) {
        print("invite link tapped")
        let textToShare = "Comrade, join fight from link if dare."
        
        if let gameID = currentGame?.id {
            if let krolikURL = NSURL(string: "krolik://\(gameID)") {
                let objectsToShare = [textToShare, krolikURL] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                activityVC.popoverPresentationController?.sourceView = sender
                self.present(activityVC, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: Game Status
    
    func checkGameState() {
        if let currentGame = currentGame {
            if currentGame.state == Game.state.pending {
                if let tabBarItems = self.tabBarController?.tabBar.items as AnyObject as? NSArray,let tabBarItem = tabBarItems[1] as? UITabBarItem {
                    tabBarItem.isEnabled = false
                }
            }else if currentGame.state == Game.state.active {
                if let tabBarItems = self.tabBarController?.tabBar.items as AnyObject as? NSArray,let tabBarItem = tabBarItems[1] as? UITabBarItem {
                    tabBarItem.isEnabled = true
                }
            }else if currentGame.state == Game.state.ended {
                if let tabBarItems = self.tabBarController?.tabBar.items as AnyObject as? NSArray,let tabBarItem = tabBarItems[1] as? UITabBarItem {
                    tabBarItem.isEnabled = false
                    performSegue(withIdentifier: "quitFromStatus", sender: self)
                }
            }
        }
    }
    
}
