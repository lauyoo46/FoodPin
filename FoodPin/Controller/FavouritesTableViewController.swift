//
//  FavouritesTableViewController.swift
//  FoodPin
//
//  Created by Laurentiu Ile on 04/01/2021.
//

import UIKit
import CoreData

class FavouritesTableViewController: UITableViewController {
    
    var favorites: [RestaurantMO] = []
    var fetchResultController: NSFetchedResultsController<RestaurantMO>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.cellLayoutMarginsFollowReadableWidth = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "Rubik-Medium", size: 40.0) {
            navigationController?.navigationBar.largeTitleTextAttributes =
                [ NSAttributedString.Key.foregroundColor:
                    FoodPin.Color.myRed.uiColor,
                  NSAttributedString.Key.font: customFont ]
        }
        navigationController?.hidesBarsOnSwipe = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
        tableView.reloadData()
    }
    
    @objc func fetchData() {
        let predicate = NSPredicate(format: "favorite == %@", NSNumber(value: true))
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<RestaurantMO> = RestaurantMO.fetchRequest()
            fetchRequest.predicate = predicate
            
            do {
                favorites = try context.fetch(fetchRequest)
            } catch {
                print("Could not fetch. \(error)")
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FavoriteCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            as? FavoriteTableViewCell
        
        guard let safeCell = cell else {
            return UITableViewCell()
        }
        
        safeCell.restaurantImage.image = UIImage(data: (favorites[indexPath.row].image ?? Data()) as Data)
        safeCell.nameLabel.text = favorites[indexPath.row].name
        safeCell.typeLabel.text = favorites[indexPath.row].type
        safeCell.mapImage.image = UIImage(systemName: "location")
        safeCell.addressLabel.text = favorites[indexPath.row].location
        safeCell.phoneImage.image = UIImage(systemName: "phone")
        safeCell.phoneLabel.text = favorites[indexPath.row].phone
        safeCell.descriptionLabel.text = favorites[indexPath.row].summary
        
        return safeCell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let unfavoriteAction = UIContextualAction(style: .normal, title: "Unfavorite") {(_, _, completionHandler) in
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                self.favorites[indexPath.row].favorite = false
                self.favorites.remove(at: indexPath.row)
                tableView.reloadData()
                appDelegate.saveContext()
            }
            completionHandler(true)
        }
        
        unfavoriteAction.backgroundColor = FoodPin.Color.myFavorite.uiColor
        unfavoriteAction.image = UIImage(systemName: "star.slash")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [unfavoriteAction])
        return swipeConfiguration
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400.0
    }
    
}
