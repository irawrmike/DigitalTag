//
//  Game.swift
//  Krolik
//
//  Created by Mike Stoltman, Mike Cameron, and Colin Russell
//  Copyright © 2018 Krolik Team. All rights reserved.
//

import Firebase

class Game {
    
    var databaseRef: DatabaseReference!
    var gameRef: DatabaseReference!
    var playerRef: DatabaseReference!
    var players = [String]()
    var owner: Bool = false
    
    func addPlayer(gameID: String) {
        let newPlayerKey = playerRef.childByAutoId().key
        
        var player = [String:Any?]()
        player["player_id"] = newPlayerKey
        player["game_id"] = gameID
        player["target_id"] = "***INSERT TARGET***"
        player["player_nickname"] = "***INSERT NICKNAME***"
        player["player_state"] = "alive"
        player["device_id"] = "***INSERT DEVICE ID***"
        player["photo_url"] = "***INSERT URL***"
        
        playerRef.child(newPlayerKey).setValue(player)
        players.append(newPlayerKey)
        
        print("player added with key \(newPlayerKey)")
    }
    
    func setupGame() {
        let newGameKey = gameRef.childByAutoId().key
        
        var game = [String:Any?]()
        game["game_id"] = newGameKey
        game["game_name"] = "Odessa Chronicles"
        game["game_players"] = []
        gameRef.child(newGameKey).setValue(game)
        gameRef.child(newGameKey).child("game_players").observe(.value) { (snapshot) in
            guard let players = snapshot.value as? [String] else {
                print("could not get players from game")
                return
            }
            self.players = players
            // reload collection view with players as they populate
        }
    }
    
    func startGame() {
        let shuffledPlayers = players.shuffled()
        
        var targetsUpdate = [String:String]()
        
        for i in 0..<shuffledPlayers.count {
            if i == (shuffledPlayers.count - 1) {
                targetsUpdate["\(shuffledPlayers[i])/target_id/"] = shuffledPlayers[0]
            }else{
                targetsUpdate["\(shuffledPlayers[i])/target_id/"] = shuffledPlayers[i+1]
            }
        }
        
        playerRef.updateChildValues(targetsUpdate)
    }
    
    func killPlayer(playerID: String, targetID: String) {
        // get new target from killed agent
        guard let newTarget = playerRef.child(targetID).value(forKey: "target_id") as? String else {
            print("could not get new target from database")
            return
        }
        
        // kill agent by setting player_state
        let killUpdate = ["player_state":"dead", "target_id":"none"]
        playerRef.child(playerID).updateChildValues(killUpdate)
        
        // assign new target to killer
        let updateTarget = ["target_id":newTarget]
        playerRef.child(playerID).updateChildValues(updateTarget)
        
        // send push notification
    }
    
    func deleteGame(gameID: String) {
        // get a list of all players within the game and delete them
        guard let players = gameRef.child(gameID).value(forKey: "game_players") as? [String] else {
            print("could not get list of players from game")
            return
        }
        for player in players {
            playerRef.child(player).removeValue()
        }
        // delete game
        gameRef.child(gameID).removeValue()
    }
}

// MARK: Functions for shuffling

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
