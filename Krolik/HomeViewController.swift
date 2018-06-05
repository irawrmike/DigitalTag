//
//  HomeViewController.swift
//  Krolik
//
//  Created by Colin Russell, Mike Cameron, and Mike Stoltman
//  Copyright © 2018 Krolik Team. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var joinGameButton: UIButton!
    @IBOutlet weak var startGameButton: UIButton!
    let testGame = "-LEBbbIMPLjDgXMBIaP-"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.string(forKey: Game.keys.id) != nil {
            performSegue(withIdentifier: "gameInProgress", sender: nil)
        }
    }
    
    @IBAction func joinButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        
    }
}
