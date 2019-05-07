//
//  HighScoresViewController.swift
//  AsteriodGame
//
//  Created by meekit on 5/6/19.
//  Copyright © 2019 meekit. All rights reserved.
//

import UIKit

class HighScoresViewController: UIViewController, UITableViewDataSource {
    
    private var data:[Int] = []

    @IBOutlet weak var MenuButton: UIButton!
    @IBAction func MenuAction(_ sender: Any) {
        performSegue(withIdentifier: "MenuView", sender: self)
    }
    
    @IBOutlet weak var HighScoresTable: UITableView!
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")! //1.

        return cell //4.
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HighScoresTable.dataSource = self
        // Do any additional setup after loading the view.
    }

}
