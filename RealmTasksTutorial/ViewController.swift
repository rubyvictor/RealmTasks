//
//  ViewController.swift
//  RealmTasksTutorial
//
//  Created by Victor Lee on 22/5/17.
//  Copyright © 2017 VictorLee. All rights reserved.
//

import UIKit
import RealmSwift

final class TaskList: Object {
    
    dynamic var text = ""
    dynamic var id = ""
    let items = List<Task>()
    
    override static func primaryKey() -> String {
        return "id"
    }
}

final class Task: Object {
    dynamic var text = ""
    dynamic var completed = false
}


class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    
    
    


}

