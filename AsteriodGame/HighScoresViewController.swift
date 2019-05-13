//
//  HighScoresViewController.swift
//  AsteriodGame
//
//  Created by meekit on 5/6/19.
//  Copyright © 2019 meekit. All rights reserved.
//

import UIKit

class HighScoresViewController: UIViewController, UITableViewDataSource {
    
    var storedHighscores = UserDefaults.standard.object(forKey: "Scores")
    
    var sortedScores : [String] = []

    @IBOutlet weak var MenuButton: UIButton!
    @IBAction func MenuAction(_ sender: Any) {
        performSegue(withIdentifier: "MenuView", sender: self)
    }
    
    @IBOutlet weak var HighScoresTable: UITableView!
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storedHighscores == nil ? 0 : (storedHighscores as! [String: String]).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "cellReuseIdentifier") //1.
        
        let score = sortedScores[indexPath.row]
        let time = (storedHighscores as! [String: String])[score]
        
        cell.textLabel!.text = "\(indexPath.row + 1): \(score) pts"
        cell.detailTextLabel!.text = time
        
        return cell //4.
    }

    func sortScores() {
        /*let highscoreKeys = storedHighscores!.keys
        let currTime = Date().description(with : .current)
        
        if highscoreKeys.count < 10 {
            storedHighscores![score!] = currTime
        } else {
        
            let scoreMin = highscoreKeys.min()
            // let scoreMax = highscoreKeys.max()
        
            if score! >= scoreMin! {
                storedHighscores!.removeValue(forKey: scoreMin!)
                storedHighscores![score!] = currTime
            }
        }*/
        
        if storedHighscores != nil {
            sortedScores = Array((storedHighscores as! [String: String]).keys).sorted().reversed()
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HighScoresTable.dataSource = self
        // Do any additional setup after loading the view.
    }

}
