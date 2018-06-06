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
    var currentGame: Game!
    var currentPlayers: [Player] = []
    let database = DatabaseManager()
    let game = GameLogic()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        database.read(gameID: currentGame.id) { (game) in
            guard let game = game else {
                print("game read returned nil value")
                return
            }
            self.currentGame = game
            let players = Array(game.players.keys)
            
            for player in players {
                self.database.read(playerID: player, completion: { (player) in
                    self.currentPlayers = []
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
        
        getDataFromUrl(url: URL(string: player.photoURL)!) { (data, response, error) in
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
        game.startGame()
    }
    
}
