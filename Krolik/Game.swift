//
//  Game.swift
//  Krolik
//
//  Created by Colin Russell, Mike Cameron, and Mike Stoltman
//  Copyright © 2018 Krolik Team. All rights reserved.
//

import Firebase

class Game {
    
    struct keys {
        static let root = "games"
        static let history = "game_history"
        static let name = "game_name"
        static let id = "game_id"
        static let players = "game_players"
        static let created = "date_created"
        static let ended = "date_ended"
    }
    
    let databaseManager = DatabaseManager()
    var name: String!
    var players = [String]()
    
    func startGame() {
        // get list of players from database
        
        // shuffle list of players
        let shuffledPlayers = players.shuffled()
        
        // create dictionary for update to database
        var targetsUpdate = [String:String]()
        
        for i in 0..<shuffledPlayers.count {
            if i == (shuffledPlayers.count - 1) {
                // last player in shuffled list gets first player
                targetsUpdate["\(shuffledPlayers[i])/\(Player.keys.target)/"] = shuffledPlayers[0]
            }else{
                // all other players in shuffled list get their index + 1
                targetsUpdate["\(shuffledPlayers[i])/\(Player.keys.target)/"] = shuffledPlayers[i+1]
            }
        }
        // update player targets on database
        
    }
    
    static func generateGameName() -> String {
        let names = ["The Odessa Files", "The Munich Gambit", "The Ostravsky Affair", "Smiley's Lament", "The Prague Chronicles", "The Vienna Waltz", "The Leningrad Let-Down"]
        let randomIndex = Int(arc4random_uniform(UInt32(names.count)))
        let name = names[randomIndex]
        return name
    }

}

// MARK: Functions for shuffling players

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
