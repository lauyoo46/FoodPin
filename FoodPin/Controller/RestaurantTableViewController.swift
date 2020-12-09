//
//  RestaurantTableViewController.swift
//  FoodPin
//
//  Created by Laurentiu Ile on 03/12/2020.
//

import UIKit

class RestaurantTableViewController: UITableViewController {

    var restaurants:[Restaurant] = [
        Restaurant(name: "Cafe Deadend", type: "Coffee & Tea Shop", location: "Hong Kong", image: "cafedeadend", isVisited: false),
        Restaurant(name: "Homei", type: "Cafe", location: "Hong Kong", image: "homei", isVisited: false),
        Restaurant(name: "Teakha", type: "Tea House", location: "Hong Kong", image: "teakha", isVisited: false),
        Restaurant(name: "Cafe loisl", type: "Austrian / Causual Drink", location: "Hong Kong", image: "cafeloisl", isVisited: false),
        Restaurant(name: "Petite Oyster", type: "French", location: "Hong Kong", image: "petiteoyster", isVisited: false),
        Restaurant(name: "For Kee Restaurant", type: "Bakery", location: "HongKong", image: "forkeerestaurant", isVisited: false),
        Restaurant(name: "Po's Atelier", type: "Bakery", location: "Hong Kong", image: "posatelier", isVisited: false),
        Restaurant(name: "Bourke Street Backery", type: "Chocolate", location: "Sydney", image: "bourkestreetbakery", isVisited: false),
        Restaurant(name: "Haigh's Chocolate", type: "Cafe", location: "Sydney", image: "haighschocolate", isVisited: false),
        Restaurant(name: "Palomino Espresso", type: "American / Seafood", location: "Sydney", image: "palominoespresso", isVisited: false),
        Restaurant(name: "Upstate", type: "American", location: "New York", image: "upstate", isVisited: false),
        Restaurant(name: "Traif", type: "American", location: "New York", image: "traif", isVisited: false),
        Restaurant(name: "Graham Avenue Meats", type: "Breakfast & Brunch", location: "New York", image: "grahamavenuemeats", isVisited: false),
        Restaurant(name: "Waffle & Wolf", type: "Coffee & Tea", location: "NewYork", image: "wafflewolf", isVisited: false),
        Restaurant(name: "Five Leaves", type: "Coffee & Tea", location: "New York", image: "fiveleaves", isVisited: false),
        Restaurant(name: "Cafe Lore", type: "Latin American", location: "New York", image: "cafelore", isVisited: false),
        Restaurant(name: "Confessional", type: "Spanish", location: "New York", image: "confessional", isVisited: false),
        Restaurant(name: "Barrafina", type: "Spanish", location: "London", image: "barrafina", isVisited: false),
        Restaurant(name: "Donostia", type: "Spanish", location: "London", image: "donostia", isVisited: false),
        Restaurant(name: "Royal Oak", type: "British", location: "London", image: "royaloak", isVisited: false),
        Restaurant(name: "CASK Pub and Kitchen", type: "Thai", location: "Lond on", image: "caskpubkitchen", isVisited: false)
        ]
    
    // MARK: - View Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.cellLayoutMarginsFollowReadableWidth = true
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "datacell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RestaurantTableViewCell

        if let safeCell = cell {
            safeCell.nameLabel.text = restaurants[indexPath.row].name
            safeCell.thumbnailImageView.image = UIImage(named: restaurants[indexPath.row].image)
            safeCell.locationLabel.text = restaurants[indexPath.row].location
            safeCell.typeLabel.text = restaurants[indexPath.row].type
            if restaurants[indexPath.row].isVisited {
                cell?.checkmarkImage.isHidden = false
            } else {
                cell?.checkmarkImage.isHidden = true
            }
            return safeCell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView,
                              trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
                            -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete")
        { (action, sourceView, completionHandler) in
            self.restaurants.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
                completionHandler(true)
        }
        
        let shareAction = UIContextualAction(style: .normal, title: "Share")
        { (action, sourceView, completionHandler) in
            let defaultText = "Just checking in at " + self.restaurants[indexPath.row].name
            let activityController: UIActivityViewController
            if let imageToShare = UIImage(named: self.restaurants[indexPath.row].image) {
                activityController = UIActivityViewController(activityItems:
                                     [ defaultText, imageToShare], applicationActivities: nil)
            } else {
                activityController = UIActivityViewController(activityItems: [defaultText],
                                     applicationActivities: nil)
            }
            
            if let popoverController = activityController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
            
            self.present(activityController, animated: true, completion: nil)
                completionHandler(true)
        }
        
        deleteAction.backgroundColor = FoodPin.Color.deleteRed.uiColor
        deleteAction.image = UIImage(systemName: "trash")
        shareAction.backgroundColor = FoodPin.Color.shareOrange.uiColor
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        return swipeConfiguration
    }
    
    override func tableView(_ tableView: UITableView,
                              leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
                              -> UISwipeActionsConfiguration?{
        let checkInAction = UIContextualAction(style: .normal, title: "Check in")
        { (action, sourceView, completionHandler) in
            if let safeCell = tableView.cellForRow(at: indexPath) as? RestaurantTableViewCell {
                safeCell.checkmarkImage.isHidden = false
                self.restaurants[indexPath.row].isVisited = true
            }
            completionHandler(true)
        }
        
        let uncheckAction = UIContextualAction(style: .normal, title: "Uncheck")
        { (action, sourceView, completionHandler) in
            if let safeCell = tableView.cellForRow(at: indexPath) as? RestaurantTableViewCell {
                safeCell.checkmarkImage.isHidden = true
                self.restaurants[indexPath.row].isVisited = false
            }
            completionHandler(true)
        }
        
        checkInAction.backgroundColor = FoodPin.Color.checkGreen.uiColor
        checkInAction.image = UIImage(systemName: "checkmark")
        uncheckAction.backgroundColor = FoodPin.Color.checkGreen.uiColor
        uncheckAction.image = UIImage(systemName: "arrow.uturn.left")
        
        var swipeConfiguration: UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: [])
        if let safeCell = tableView.cellForRow(at: indexPath) as? RestaurantTableViewCell {
            if safeCell.checkmarkImage.isHidden == false {
                swipeConfiguration = UISwipeActionsConfiguration(actions: [uncheckAction])
            } else {
                swipeConfiguration = UISwipeActionsConfiguration(actions: [checkInAction])
            }
        }
        
        return swipeConfiguration
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! RestaurantDetailViewController
                destinationController.restaurant = restaurants[indexPath.row]
            }
        }
    }
}
