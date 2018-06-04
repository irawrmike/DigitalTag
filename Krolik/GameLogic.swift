//
//  GameLogic.swift
//  Krolik
//
//  Created by Mike Stoltman on 2018-06-04.
//  Copyright © 2018 Mike Stoltman. All rights reserved.
//

import Foundation
import Firebase

class GameLogic {

    var players = [String]()
    let database = DatabaseManager()
    
    func createGame() {
        
    }
    
    func startGame() {
        
    }
    
    func createTargets(game: Game) {
        
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
        database.updatePlayers(update: targetsUpdate)
    }
    
}

// MARK: Database Delegate Functions

extension GameLogic: DatabaseDelegate {
    
    func readGame(game: Game) {
        
    }
    
    func readPlayer(player: Player) {
        
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
