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
        static let owner = "game_owner"
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
    var photoURL: String!
    var isDM: Bool = false
    
    static func generatePlayerName() -> String {
        let names = ["Switchblade", "Honey Badger", "the Rattlesnake", "Omega Prime", "the Blade", "Shovelhead", "Nuke", "the Silent Wizard", "Marmot Alpha", "the auld Claymore", "Goosefeather", "Blackjack", "the Demon Dog", "Sidewinder", "Tomahawk", "Maverick from Top Gun", "Some Kind of Gremlin", "the Pink Ninja", "the Ender of Worlds", "Terminal Master"]
        let randomIndex = Int(arc4random_uniform(UInt32(names.count)))
        let name = names[randomIndex]
        return name
    }
    
}
