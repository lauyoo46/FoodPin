//
//  ViewController.swift
//  FoodPin
//
//  Created by Laurentiu Ile on 02/12/2020.
//

import UIKit

class FoodPinViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var restaurantNames = ["Cafe Deadend", "Homei", "Teakha", "Cafe Loisl", "P etite Oyster",
                           "For Kee Restaurant", "Po's Atelier", "Bourke Street Bakery" ,
                           "Haigh's Chocolate", "Palomino Espresso", "Upstate", "Traif",
                           "Graham Av enue Meats And Deli", "Waffle & Wolf", "Five Leaves",
                           "Cafe Lore", "Confes sional", "Barrafina", "Donostia", "Royal Oak",
                           "CASK Pub and Kitchen"]

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "datacell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = restaurantNames[indexPath.row]
        cell.imageView?.image = UIImage(named: "restaurant")
        
        return cell
    }

}
