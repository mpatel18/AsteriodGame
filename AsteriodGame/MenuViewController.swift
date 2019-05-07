//
//  MenuViewController.swift
//  AsteriodGame
//
//  Created by meekit on 5/6/19.
//  Copyright © 2019 meekit. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var NewGameButton: UIButton!
    @IBAction func NewGameAction(_ sender: Any) {
        performSegue(withIdentifier: "GameView", sender: self)
    }
    
    @IBOutlet weak var HighScoresButton: UIButton!
    @IBAction func HighScoresAction(_ sender: Any) {
        performSegue(withIdentifier: "HighScoreView", sender: self)
    }
    
    @IBOutlet weak var HelperButton: UIButton!
    @IBAction func HelperAction(_ sender: Any) {
        performSegue(withIdentifier: "HelperView", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }
}
