//
//  Player.swift
//  Krolik
//
//  Created by Colin Russell, Mike Cameron, and Mike Stoltman
//  Copyright © 2018 Krolik Team. All rights reserved.
//

import Foundation

class Player {
    
    // MARK: Keys
    
    struct keys {
        static let root = "players"
        static let id = "player_id"
        static let target = "player_target"
        static let nickname = "player_nickname"
        static let state = "player_state"
        static let photo = "player_photo"
        static let device = "player_device"
        static let killedBy = "killed_by"
    }
    
    struct state {
        static let alive = "alive"
        static let dead = "dead"
    }
    
    // MARK: Properties
    
    var id: String!
    var target: String!
    var nickname: String!
    var state: String!
    var device: String!
    
    static func generatePlayerName() -> String {
        let names = ["The Odessa Files", "The Munich Gambit", "The Ostravsky Affair", "Smiley's Lament", "The Prague Chronicles", "The Vienna Waltz", "The Leningrad Let-Down"]
        let randomIndex = Int(arc4random_uniform(UInt32(names.count)))
        let name = names[randomIndex]
        return name
    }
    
}
