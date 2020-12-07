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
    
    var restaurantLocations = ["Hong Kong", "Hong Kong", "Hong Kong", "Hong Kong", "Hong Kong", "Hong Kong",
                               "Hong Kong", "Sydney", "Sydney", "Sydney", "New York", "New York", "New York",
                               "New York", "New York", "New York", "N ew York", "London", "London", "London", "London"]
    
    var restaurantTypes = ["Coffee & Tea Shop", "Cafe", "Tea House", "Austrian / Causual Drink", "French",
                           "Bakery", "Bakery", "Chocolate", "Cafe", "American / Seafood", "American", "American",
                           "Breakfast & Brunch", "Coffee & Tea", "Coffee & Tea", "Latin American", "Spanish",
                           "Spanish", "Spanish", " British", "Thai"]
    
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
            safeCell.locationLabel.text = restaurantLocations[indexPath.row]
            safeCell.typeLabel.text = restaurantTypes[indexPath.row]

            return safeCell
        }
        
        return UITableViewCell()
    }

}
