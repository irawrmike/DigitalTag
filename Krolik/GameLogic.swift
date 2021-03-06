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
    
    func createGame() {
        // create game object on database and locally
        currentGame = database.createGame()
        currentPlayer.isDM = true
    }
    
    func startGame() {
        // create targets and send to database
        database.read(gameID: currentGame.id) { (game) in
            // assign returned game value to current game property
            self.currentGame = game
            
            if game?.state == Game.state.pending {
                self.createTargets(game: game!)
            }
            
        }
    }
    
    func createTargets(game: Game) {
        
        // shuffle list of players
        let playersArray = Array(game.players.keys)
        let shuffledPlayers = playersArray.shuffled()
        
        // create dictionary for update to database
        var targetsUpdate = [String:String]()
        
        for i in 0..<shuffledPlayers.count {
            if shuffledPlayers.count == 1 {
                print("can't start game with 1 player.")
            }else {
                if i == (shuffledPlayers.count - 1) {
                    // last player in shuffled list gets first player
                    targetsUpdate["\(shuffledPlayers[i])/\(Player.keys.target)/"] = shuffledPlayers[0]
                    targetsUpdate["\(shuffledPlayers[i])/\(Player.keys.assassin)/"] = shuffledPlayers[i-1]
                }else if i == 0 {
                    // first player is chased by last player
                    targetsUpdate["\(shuffledPlayers[i])/\(Player.keys.target)/"] = shuffledPlayers[i+1]
                    targetsUpdate["\(shuffledPlayers[i])/\(Player.keys.assassin)/"] = shuffledPlayers[shuffledPlayers.count-1]
                }else{
                    // all other players in shuffled list get their index + 1
                    targetsUpdate["\(shuffledPlayers[i])/\(Player.keys.target)/"] = shuffledPlayers[i+1]
                    targetsUpdate["\(shuffledPlayers[i])/\(Player.keys.assassin)/"] = shuffledPlayers[i-1]
                }
            }
            // update player targets on database
            database.updatePlayers(update: targetsUpdate)
            database.update(gameID: currentGame.id, update: [Game.keys.state : Game.state.active])
        }
    }
    
    func fetchTarget (player: Player) -> String {
        //GIVEN A PLAYER RETURN THE PLAYERID OF THEIR TARGET
        
        return "playerId"
    }
    
    func tryToKill (player: Player, target: Player) -> Bool {
        return true
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
