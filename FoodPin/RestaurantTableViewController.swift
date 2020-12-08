//
//  RestaurantTableViewController.swift
//  FoodPin
//
//  Created by Laurentiu Ile on 03/12/2020.
//

import UIKit

class RestaurantTableViewController: UITableViewController {

    var restaurantNames = ["Cafe Deadend", "Homei", "Teakha", "Cafe Loisl", "Petite Oyster",
                           "For Kee Restaurant", "Po's Atelier", "Bourke Street Bakery",
                           "Haigh's Chocolate", "Palomino Espresso", "Upstate", "Traif",
                           "Graham Avenue Meats And Deli", "Waffle & Wolf", "Five Leaves", "Cafe Lore",
                           "Confessional", "Barrafina", "Donostia", "Royal Oak", "CASK Pub and Kitchen"]
    
    var restaurantImages = ["Cafe Deadend", "Homei", "Teakha", "Cafe Loisl", "Petite Oyster",
                            "For Kee Restaurant", "Po's Atelier", "Bourke Street Bakery",
                            "Haigh's Chocolate", "Palomino Espresso", "Upstate", "Traif",
                            "Graham Avenue Meats And Deli", "Waffle & Wolf", "Five Leaves", "Cafe Lore",
                            "Confessional", "Barrafina", "Donostia", "Royal Oak", "CASK Pub and Kitchen"]
    
    var restaurantIsVisited = Array(repeating: false, count: 21)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.cellLayoutMarginsFollowReadableWidth = true
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "datacell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RestaurantTableViewCell

        if let safeCell = cell {
            safeCell.nameLabel.text = restaurantNames[indexPath.row]
            safeCell.thumbnailImageView.image = UIImage(named: restaurantImages[indexPath.row])
            if restaurantIsVisited[indexPath.row] {
                cell?.accessoryType = .checkmark
            } else {
                cell?.accessoryType = .none
            }
            return safeCell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let optionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: .actionSheet)
        
        if let popoverController = optionMenu.popoverPresentationController {
            if let cell = tableView.cellForRow(at: indexPath) {
                popoverController.sourceView = cell
                popoverController.sourceRect = cell.bounds
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        optionMenu.addAction(cancelAction)
        
        let callActionHandler = { (action: UIAlertAction!) -> Void in
            let alertMessage = UIAlertController(title: "Service Unavailable",
                                                 message: "Sorry, the call feature is not available yet. Please retry later.",
                                                 preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertMessage, animated: true, completion: nil)
        }
        let callAction = UIAlertAction(title: "Call " + "123-000-\(indexPath.row)",
                                       style: .default,
                                       handler: callActionHandler)
        optionMenu.addAction(callAction)
        
        let checkInAction = UIAlertAction(title: "Check in",
                                          style: .default,
                                          handler: { (action:UIAlertAction!) -> Void in
                                                let cell = tableView.cellForRow(at: indexPath)
                                                cell?.accessoryType = .checkmark
                                                self.restaurantIsVisited[indexPath.row] = true
                                          })
        let uncheckAction = UIAlertAction(title: "Uncheck",
                                          style: .default,
                                          handler: { (action: UIAlertAction!) -> Void in
                                                let cell = tableView.cellForRow(at: indexPath)
                                                cell?.accessoryType = .none
                                                self.restaurantIsVisited[indexPath.row] = false
                                          })
        if restaurantIsVisited[indexPath.row] == false {
            optionMenu.addAction(checkInAction)
        } else {
            optionMenu.addAction(uncheckAction)
        }
        
        present(optionMenu, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }

}
