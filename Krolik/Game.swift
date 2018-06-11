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
        static let join = "join_id"
        static let players = "game_players"
        static let devices = "game_device"
        static let state = "state"
        static let created = "date_created"
        static let ended = "date_ended"
        static let winner = "winner"
    }
    
    struct state {
        static let pending = "pending"
        static let active = "active"
        static let ended = "ended"
    }
    
    let databaseManager = DatabaseManager()
    var name: String!
    var id: String!
    var players = [String:String]()
    var kills = [String]()
    var created: String!
    var ended: String?
    var state: String!
    
    static func generateGameName() -> String {
        //let names = ["The Odessa Files", "The Munich Gambit", "The Ostravsky Affair", "Smiley's Lament", "The Prague Chronicles", "The Vienna Waltz", "The Leningrad Let-Down"]
        let cities = ["Tirana", "Andorra", "Baku", "Minsk", "Munich", "Ostravsky", "Smiley's", "Odessa", "Prague", "Vienna", "Leningrad", "Brussels", "Sofia", "Zagreb", "Tallinn", "Helsinki", "Tbilisi", "Buda", "Pest", "Dublin", "Rome"]
        let nouns = ["Files", "Gambit", "Affair", "Lament", "Elegy", "Chronicles", "Let-Down", "Come-Up", "Waltz", "Two-Step", "Freakout", "Breakdown", "Murder Party"]
        let randomIndexA = Int(arc4random_uniform(UInt32(cities.count)))
        let randomIndexB = Int(arc4random_uniform(UInt32 (nouns.count)))
        let name : String = "The \(cities[randomIndexA]) \(nouns[randomIndexB])"
        return name
    }

}
