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
        label.textColor = .black
        label.backgroundColor = .white
       
        return label
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupRealm()
        view.backgroundColor = .yellow
        
        // initial dummy task
//        items.append(Task(value: ["text":"My First Task"]))
        
    }

    var cell = "cell"
    func setupUI() {
        navigationItem.title = "My Tasks"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cell)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAdd))
        navigationItem.leftBarButtonItem = editButtonItem
    }

    
    
    // Set up Realm and deinit
    func setupRealm() {
        let username = "myleevictor@gmail.com"
        let password = "Realmofvictory88"
        
        SyncUser.logIn(with: .usernamePassword(username: username, password: password, register: false), server: URL(string: "http://127.0.0.1:9080")!) { user, error in
            if let error = error {
            print("Failed to log in to Realm", error)
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
                    
                    guard let list = self.realm.objects(TaskList.self).first else { return }
                    
                    if self.items.realm == nil {
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
    
    func handleAdd() {
        let alertController = UIAlertController(title: "New Task", message: "Enter Task Name", preferredStyle: .alert)
        var alertTextField: UITextField!
        alertController.addTextField { textField in
            alertTextField = textField
            textField.placeholder = "Task Name"
        }
        alertController.addAction(UIAlertAction(title: "Add", style: .default) { _ in
                guard let text = alertTextField.text , !text.isEmpty else { return }
                
                let items = self.items
                try! items.realm?.write {
                    items.insert(Task(value: ["text": text]), at: items.filter("completed = false").count)
                }
            
//                self.items.append(Task(value: ["text": text]))
//                self.tableView.reloadData()
        })
        present(alertController, animated: true, completion: nil)
    }
    

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        try! items.realm?.write {
            items.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if isEditing == true {
            try! realm.write {
                    let item = items[indexPath.row]
                    realm.delete(item)
            }
        }
        return .delete
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

