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
    var currentGame: Game!
    var currentPlayer : Player = Player()
    var currentTarget : Player = Player()
//    var userDefaults = UserDefaults.standard
    
    
    func createGame() {
        // create game object on database and locally
        currentGame = database.createGame()
    }
    
    func startGame() {
        // create targets and send to database
        self.players = fetchPlayers(game: currentGame)
        //call create Targets
        createTargets(game: currentGame)
    }
    //NEED DATABASE STUFF HERE COPY FROM GAMESTATUSVIEWCONTROLLER
    func fetchPlayers(game: Game) -> [String] {
        //get players from game.id from Database
        let fetchedPlayers = [String]()
        return fetchedPlayers
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
    
    func fetchTarget (player: Player) -> String {
        //GIVEN A PLAYER RETURN THE PLAYERID OF THEIR TARGET
        return "playerId"
    }
    
    func tryToKill (player: Player, target: Player) -> Bool {
        return true
    }
    
    
}

// MARK: Database Delegate Functions

extension GameLogic: DatabaseDelegate {
    
    func readGame(game: Game?) {
        // assign returned game value to current game property
        currentGame = game
        
        // run code on returned game object here
    }
    
    func readPlayer(player: Player?) {
        
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
