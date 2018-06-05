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
    var id: String!
    var players = [String:String]()
    var kills = [String]()
    var created: String!
    var ended: String?
    
    static func generateGameName() -> String {
        let names = ["The Odessa Files", "The Munich Gambit", "The Ostravsky Affair", "Smiley's Lament", "The Prague Chronicles", "The Vienna Waltz", "The Leningrad Let-Down"]
        let randomIndex = Int(arc4random_uniform(UInt32(names.count)))
        let name = names[randomIndex]
        return name
    }

}
