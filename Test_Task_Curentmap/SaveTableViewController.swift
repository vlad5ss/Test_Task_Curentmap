//
//  SaveTableViewController.swift
//  Test_Task_Curentmap
//
//  Created by mac on 4/13/17.
//  Copyright © 2017 mac. All rights reserved.
//

import UIKit

var places = [Dictionary<String, String>()]
var activePlace = -1

class SaveTableViewController:   UITableViewController {

    @IBOutlet var table: UITableView!
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
    }

    override func viewWillAppear(_ animated: Bool) {

        if let tempPlaces = UserDefaults.standard.object(forKey: "places") as? [Dictionary<
            String, String>] {
             places = tempPlaces
        }

        if places.count == 1 && places[0].count == 0 {

            places.remove(at: 0)

            places.append(["name": "Rim bolnica", "lat": "41.859152", "lon": "12.451856"])

            UserDefaults.standard.set(places, forKey: "places")
        }

        activePlace = -1
        table.reloadData()
        table.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            places.remove(at: indexPath.row)
            UserDefaults.standard.set(places, forKey: "places")
            table.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        if places[indexPath.row]["name"] != nil {
            cell.textLabel?.text = places[indexPath.row]["name"]
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activePlace = indexPath.row
        performSegue(withIdentifier: "toMap", sender: nil)
    }



    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = places[fromIndexPath.row]
        places.remove(at: fromIndexPath.row)
        places.insert(itemToMove, at: fromIndexPath.row)
    }
}
