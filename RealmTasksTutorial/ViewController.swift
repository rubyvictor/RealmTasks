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
    var notificationToken: NotificationToken!
    var realm: Realm!
    
    let textlabel: UILabel = {
        let label = UILabel()
        
       
        return label
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupRealm()
        
        // initial dummy task
//        items.append(Task(value: ["text":"My First Task"]))
        
    }

    var cell = "cell"
    fileprivate func setupUI() {
        navigationItem.title = "My Tasks"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cell)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAdd))
    }

    func handleAdd() {
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
    
    // Set up Realm and deinit
    func setupRealm() {
        let username = "myleevictor@gmail.com"
        let password = "Realmofvictory88"
        
        SyncUser.logIn(with: .usernamePassword(username: username, password: password, register: false), server: URL(string: "http://127.0.0.1:9080")!) { user, error in
            if error != nil {
            fatalError(error as! String)
            }
            
            DispatchQueue.main.async {
                // Open Realm
                if let user = user {
                    let configuration = Realm.Configuration(syncConfiguration: SyncConfiguration(user: user, realmURL: URL(string: "realm://127.0.0.1:9080/~/realmtasks")!))
                    // Make the try! force optional
                    self.realm = try! Realm(configuration: configuration)
                }
                // Show initial tasks
                func updateList() {
                    if self.items.realm == nil, let list = self.realm.objects(TaskList.self).first {
                        self.items = list.items
                    }
                    self.tableView.reloadData()
                }
                updateList()
                
                // Notify us when Realm changes
                self.notificationToken = self.realm.addNotificationBlock { _ in
                    updateList()
                }
            }
        }
    }

    deinit {
        notificationToken.stop()
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
    



}

