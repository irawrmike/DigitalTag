//
//  GameLogic.swift
//  Krolik
//
//  Created by Mike Stoltman on 2018-06-04.
//  Copyright © 2018 Mike Stoltman. All rights reserved.
//

import Foundation

class GameLogic {

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
    
}
