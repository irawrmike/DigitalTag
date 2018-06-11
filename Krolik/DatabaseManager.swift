//
//  DatabaseManager.swift
//  Krolik
//
//  Created by Colin Russell, Mike Cameron, and Mike Stoltman
//  Copyright © 2018 Krolik Team. All rights reserved.
//

import Firebase
import FirebaseDatabase


class DatabaseManager {
    
    // MARK: PROPERTIES
    
    var databaseRef: DatabaseReference!
    
    // MARK: CREATE
    
    // CREATE GAME
    func createGame() -> Game {
        // create reference to games root folder
        databaseRef = Database.database().reference()
        let gamesRef = databaseRef.child(Game.keys.root)
        
        // get random key for new game
        let newGameKey = gamesRef.childByAutoId().key
        
        // create gameData dictionary using game properties
        var gameData = [String:Any?]()
        gameData[Game.keys.id] = newGameKey
        let date = "TODAY"
        gameData[Game.keys.created] = date
        let name = Game.generateGameName()
        gameData[Game.keys.name] = name
        gameData[Game.keys.players] = []
        gameData[Game.keys.devices] = []
        gameData[Game.keys.state] = Game.state.pending
        
        // create the game on the firebase database
        gamesRef.child(newGameKey).setValue(gameData)
        
        // use assigned values to create game object
        let game = Game()
        game.id = newGameKey
        game.name = name
        game.state = Game.state.pending
        game.created = date
        game.players = [String:String]()
        
        return game
    }
    
    // CREATE PLAYER
    func createPlayer(gameID: String) -> Player {
        // create reference to players root folder
        databaseRef = Database.database().reference()
        let playersRef = databaseRef.child(Player.keys.root)
        
        // get random key for new player
        let newPlayerKey = playersRef.childByAutoId().key
        
        // create playerData dictionary using player properties
        var playerData = [String:Any?]()
        playerData[Player.keys.id] = newPlayerKey
        playerData[Game.keys.id] = gameID
//        playerData[Player.keys.target] = "***INSERT TARGET***"
        let nickname = Player.generatePlayerName()
        playerData[Player.keys.nickname] = nickname
        guard let device = UserDefaults.standard.value(forKey: "FCMToken") as? String else { return Player()}
        playerData[Player.keys.device] = device
        let photo = "***INSERT URL***"
        playerData[Player.keys.photo] = photo
        
        // create the player on firebase database
        playersRef.child(newPlayerKey).setValue(playerData)
        
        // add device to game devices
        databaseRef.child(Game.keys.root).child(gameID).child(Game.keys.devices).updateChildValues([device : true])
        
        // print statement to confirm addition of new player with unique key
        print("player added with key \(newPlayerKey)")
        
        let player = Player()
        player.id = newPlayerKey
        player.nickname = nickname
        player.device = device
        
        return player
    }
    
    // MARK: READ
    
    // READ GAME
    func read(gameID: String, completion: @escaping (_ game: Game?) -> ()) {
        // create reference to games root folder
        databaseRef = Database.database().reference()
        let gamesRef = databaseRef.child(Game.keys.root)
        
        // get data snapshot of database
        gamesRef.child(gameID).observe(.value) { (snapshot) in
            // convert snapshot to dictionary
            guard let gameData = snapshot.value as? [String:Any] else {
                print("error converting game snapshot to dictionary")
                completion(nil)
                return
            }
            
            // create game object using data from dictionary
            let game = Game()
            
            game.name = gameData[Game.keys.name] as? String
            game.id = gameData[Game.keys.id] as? String
            game.players = gameData[Game.keys.players] as! [String:String]
            game.state = gameData[Game.keys.state] as? String
            if let winner = gameData[Game.keys.winner] as? [String:String] {
                game.winner = winner
            }
            completion(game)
        }
    }
    
    // READ GAME ONCE
    func readOnce(gameID: String, completion: @escaping (_ game: Game?) -> ()) {
        // create reference to games root folder
        databaseRef = Database.database().reference()
        let gamesRef = databaseRef.child(Game.keys.root)
        
        // get data snapshot of database
        gamesRef.child(gameID).observeSingleEvent(of: .value) { (snapshot) in
            // convert snapshot to dictionary
            guard let gameData = snapshot.value as? [String:Any] else {
                print("error converting game snapshot to dictionary")
                completion(nil)
                return
            }
            
            // create game object using data from dictionary
            let game = Game()
            
            game.name = gameData[Game.keys.name] as? String
            game.id = gameData[Game.keys.id] as? String
            game.players = gameData[Game.keys.players] as! [String:String]
            game.state = gameData[Game.keys.state] as? String
            
            completion(game)
        }
    }
    
    // READ PLAYER
    func read(playerID: String, completion: @escaping (_ player: Player?) -> ()) {
        // create reference to players root folder
        databaseRef = Database.database().reference()
        let playersRef = databaseRef.child(Player.keys.root)
        
        // get data snapshot of database
        playersRef.child(playerID).observeSingleEvent(of: .value) { (snapshot) in
            // convert snapshot to dictionary
            guard let playerData = snapshot.value as? [String:Any?] else {
                print("error converting player snapshot to dictionary")
                completion(nil)
                return
            }
            
            // create player object using data from dictionary
            let player = Player()
            
            player.nickname = playerData[Player.keys.nickname] as? String
            player.id = playerData[Player.keys.id] as? String
            player.target = playerData[Player.keys.target] as? String
            player.device = playerData[Player.keys.device] as? String
            player.photoURL = playerData[Player.keys.photo] as? String
            
            completion(player)
        }
    }
    
    // READ GAME HISTORY
    func read(historicalID: String, completion: @escaping (_ game: Game?) -> ()) {
        // create reference to games history root folder
        databaseRef = Database.database().reference()
        let historyRef = databaseRef.child(Game.keys.history)
        
        // get data snapshot of database
        historyRef.child(historicalID).observe(.value) { (snapshot) in
            // convert snapshot to dictionary
            guard let historyData = snapshot.value as? [String:Any] else {
                print("error converting game history snapshot to dictionary")
                completion(nil)
                return
            }
            
            // create game object using data from dictionary
            let game = Game()
            
            game.name = historyData[Game.keys.name] as? String
            game.id = historyData[Game.keys.id] as? String
            game.players = historyData[Game.keys.players] as! [String:String]
            game.created = historyData[Game.keys.created] as? String
            game.ended = historyData[Game.keys.ended] as? String
            
            completion(game)
        }
    }
    
    // MARK: UPDATE
    
    // UPDATE GAME
    func update(gameID: String, update: Dictionary<String, Any>) {
        // create reference to games root folder
        databaseRef = Database.database().reference()
        let gamesRef = databaseRef.child(Game.keys.root)
        
        // create reference to specific game via ID
        let gameRef = gamesRef.child(gameID)
        
        // update values based on dictionary
        gameRef.updateChildValues(update)
    }
    
    // UPDATE PLAYER
    func update(playerID: String, update: Dictionary<String, Any>) {
        // create reference to players root folder
        databaseRef = Database.database().reference()
        let playersRef = databaseRef.child(Player.keys.root)
        
        // create reference to specific player via ID
        let playerRef = playersRef.child(playerID)
        
        // update values based on dictionary
        playerRef.updateChildValues(update)
    }
    
    func changePlayerState(gameID: String, playerID: String, state: String) {
        let gamePlayersRef = databaseRef.child(Game.keys.root).child(gameID).child(Game.keys.players)
        gamePlayersRef.updateChildValues([playerID : state])
    }
    
    func updatePlayers(update: Dictionary<String, Any>) {
        // create reference to players root folder
        databaseRef = Database.database().reference()
        let playersRef = databaseRef.child(Player.keys.root)
        
        // update values
        playersRef.updateChildValues(update)
    }
    
    func updatePlayers(update: Dictionary<String, Any>, completion: @escaping (_ success: Bool) -> ()) {
        // create reference to players root folder
        databaseRef = Database.database().reference()
        let playersRef = databaseRef.child(Player.keys.root)
        
        // update values
        playersRef.updateChildValues(update)
        
        completion(true)
    }
    
    // MARK: DELETE
    
    // DELETE GAME
    func delete(gameID: String) {
        // create reference to games root folder
        databaseRef = Database.database().reference()
        let gamesRef = databaseRef.child(Game.keys.root)
        
        // get data snapshot of database
        gamesRef.child(gameID).observeSingleEvent(of: .value) { [weak self] (snapshot) in
            // convert snapshot to dictionary
            guard let gameData = snapshot.value as? [String:Any] else {
                print("error converting game snapshot to dictionary")
                return
            }
            
            // read players list from game
            guard let playersDict = gameData[Game.keys.players] as? [String : String] else {
                print("error: could not get players from gameData")
                return
            }
            
            let players = Array(playersDict.keys)
            
            // delete all players that were created for the game
            for player in players {
                self?.delete(playerID: player)
            }
            
            // backup game data to history
            let historyRef = self?.databaseRef.child(Game.keys.history)
            historyRef?.setValuesForKeys(gameData)
            
            // delete all values associated to specified game from database
            gamesRef.child(gameID).removeValue()
        }
    }
    
    // DELETE PLAYER
    func delete(playerID: String) {
        // create reference to players root folder
        databaseRef = Database.database().reference()
        let playersRef = databaseRef.child(Player.keys.root)
        
        // delete all values associated to specified player from database
        playersRef.child(playerID).removeValue()
    }
    
}
