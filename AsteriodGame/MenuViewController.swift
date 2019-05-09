//
//  MenuViewController.swift
//  AsteriodGame
//
//  Created by meekit on 5/6/19.
//  Copyright © 2019 meekit. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class MenuViewController: UIViewController {
    
    var backgroundMusic = "Future RPG.mp3"
    var player = AVAudioPlayer()
    var lastScore : Int?
    
    @IBOutlet weak var NewGameButton: UIButton!
    @IBAction func NewGameAction(_ sender: Any) {
        player.stop()
        performSegue(withIdentifier: "GameView", sender: self)
    }
    
    @IBOutlet weak var HighScoresButton: UIButton!
    @IBAction func HighScoresAction(_ sender: Any) {
        performSegue(withIdentifier: "HighScoreView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HighScoreView" {
            if let highScoresVC = segue.destination as? HighScoresViewController {
                highScoresVC.sortScores()
            }
        }
    }
    
    @IBOutlet weak var HelperButton: UIButton!
    @IBAction func HelperAction(_ sender: Any) {
        performSegue(withIdentifier: "HelperView", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            player = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "Future-RPG", ofType: "mp3")!))
            player.numberOfLoops = -1
            player.prepareToPlay()
            
            if !player.isPlaying {
                player.play()
            }
        }
        catch{
            print(error)
        }
        // Do any additional setup after loading the view.
    }
}
