//
//  HelperViewController.swift
//  AsteriodGame
//
//  Created by meekit on 5/6/19.
//  Copyright © 2019 meekit. All rights reserved.
//

import UIKit

class HelperViewController: UIViewController {
    
    @IBOutlet weak var MenuButton: UIButton!
    @IBAction func MenuAction(_ sender: Any) {
        performSegue(withIdentifier: "MenuView", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}
