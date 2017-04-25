//
//  SecondViewController.swift
//  
//
//  Created by mac on 4/17/17.
//
//
import UIKit
import CoreLocation


class SecondViewController:   UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    
    @IBAction func startEditing(_ sender: Any) {
        
        self.isEditing = !self.isEditing
        
        if editButton.title == "Edit" {
            editButton.title = "OK"
        } else {
            editButton.title = "Edit"
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(listRequests.count)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.numberOfLines = 2
        if listRequests[indexPath.row].toString() != nil {
        cell.textLabel?.text = listRequests[indexPath.row].toString()
                      cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    

    
    
//        override func viewDidAppear(_ animated: Bool) {
//            super.viewDidAppear(animated)
//    
//            tableView.reloadData()
//        }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            listRequests.remove(at: indexPath.row)
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: listRequests)
            UserDefaults.standard.set(encodedData, forKey: "listRequest")
            tableView.reloadData()
        }}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Show Map", sender: nil)
        history = true
        request = listRequests[indexPath.row]
        UIView.setAnimationsEnabled(false)
    }
    
    
}
