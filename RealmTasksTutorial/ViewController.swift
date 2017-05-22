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

    var items = List<Task>()
    
    let textlabel: UILabel = {
        let label = UILabel()
        
       
        return label
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        add()
//        items.append(Task(value: ["text":"My First Task"]))
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    var cell = "cell"
    fileprivate func setupUI() {
        navigationItem.title = "My Tasks"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cell)
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cell, for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.text
        cell.textLabel?.alpha = item.completed ? 0.5 : 1
        
        
        return cell
    }
    
    func add() {
        let alertController = UIAlertController(title: "New Task", message: "Enter New Task Name", preferredStyle: .alert)
        var alertTextField = UITextField()
        alertController.addTextField { (textField) in
            alertTextField = textField
            alertTextField.placeholder = "Task Name"
        }
        
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            print(action)
            guard let text = alertTextField.text, !text.isEmpty else { return }
            self.items.append(Task(value: ["text":text]))
            self.tableView.reloadData()
        }))
        
        present(alertController, animated: true, completion: nil)
        
        
        
    }


}

