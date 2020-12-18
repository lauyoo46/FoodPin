//
//  RestaurantTableViewController.swift
//  FoodPin
//
//  Created by Laurentiu Ile on 03/12/2020.
//

import UIKit
import CoreData

class RestaurantTableViewController: UITableViewController {
    
    var searchController: UISearchController?
    var searchResults: [RestaurantMO] = []
    
    @IBOutlet var emptyRestaurantView: UIView!
    var restaurants: [RestaurantMO] = []
    var fetchResultController: NSFetchedResultsController<RestaurantMO>!
    
    // MARK: - View Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.cellLayoutMarginsFollowReadableWidth = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "Rubik-Medium", size: 40.0) {
            navigationController?.navigationBar.largeTitleTextAttributes =
                [ NSAttributedString.Key.foregroundColor:
                  UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0),
                  NSAttributedString.Key.font: customFont ]
        }
        navigationController?.hidesBarsOnSwipe = true
        
        tableView.backgroundView = emptyRestaurantView
        tableView.backgroundView?.isHidden = true
        
        searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
        guard let safeSearchController = searchController else {
            return
        }
        safeSearchController.searchResultsUpdater = self
        safeSearchController.obscuresBackgroundDuringPresentation = false
        
        safeSearchController.searchBar.placeholder = "Search restaurants..."
        safeSearchController.searchBar.barTintColor = .white
        safeSearchController.searchBar.backgroundImage = UIImage()
        safeSearchController.searchBar.tintColor = FoodPin.Color.deleteRed.uiColor
        
        fetchData()
    }
    
    func fetchData() {
        let fetchRequest: NSFetchRequest<RestaurantMO> = RestaurantMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                               managedObjectContext: context,
                                                               sectionNameKeyPath: nil,
                                                               cacheName: nil)
            fetchResultController.delegate = self
            do {
                try fetchResultController.performFetch()
                if let fetchedObjects = fetchResultController.fetchedObjects {
                    restaurants = fetchedObjects
                }
            } catch {
                print(error)
            }
        }
    }
    
    func filterContent(for searchText: String) {
        searchResults = restaurants.filter({ (restaurant) -> Bool in
            if let name = restaurant.name,
               let location = restaurant.location {
                let isMatch = name.localizedCaseInsensitiveContains(searchText) ||
                              location.localizedCaseInsensitiveContains(searchText)
                return isMatch
            }
            return false
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.barStyle = .default
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {}
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if !restaurants.isEmpty {
            tableView.backgroundView?.isHidden = true
            tableView.separatorStyle = .singleLine
        } else {
            tableView.backgroundView?.isHidden = false
            tableView.separatorStyle = .none
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let safeSearchController = searchController else {
            return 0
        }
        if safeSearchController.isActive {
            return searchResults.count
        } else {
            return restaurants.count
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let safeSearchController = searchController else {
            return true 
        }
        if safeSearchController.isActive {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "datacell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RestaurantTableViewCell
        
        guard let safeSearchController = searchController else {
            return UITableViewCell()
        }
        let restaurant = (safeSearchController.isActive) ? searchResults[indexPath .row] : restaurants[indexPath.row]
        
        if let safeCell = cell {
            safeCell.nameLabel.text = restaurant.name
            if let restaurantImage = restaurant.image {
                safeCell.thumbnailImageView.image = UIImage(data: restaurantImage as Data)
            }
            safeCell.locationLabel.text = restaurant.location
            safeCell.typeLabel.text = restaurant.type
            if restaurant.isVisited {
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
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {(_, _, completionHandler) in
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                let restaurantToDelete = self.fetchResultController.object(at: indexPath)
                context.delete(restaurantToDelete)
                appDelegate.saveContext()
            }
            
            completionHandler(true)
        }
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") {(_, _, completionHandler) in
            guard let restaurantName = self.restaurants[indexPath.row].name else {
                return
            }
            let defaultText = "Just checking in at " + restaurantName
            let activityController: UIActivityViewController
            if let restaurantImage = self.restaurants[indexPath.row].image,
               let imageToShare = UIImage(data: restaurantImage as Data) {
                activityController = UIActivityViewController(activityItems: [ defaultText, imageToShare],
                                                              applicationActivities: nil)
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
                            -> UISwipeActionsConfiguration? {
        let checkInAction = UIContextualAction(style: .normal, title: "Check in") {(_, _, completionHandler) in
            if let safeCell = tableView.cellForRow(at: indexPath) as? RestaurantTableViewCell {
                safeCell.checkmarkImage.isHidden = false
                self.restaurants[indexPath.row].isVisited = true
            }
            completionHandler(true)
        }
        
        let uncheckAction = UIContextualAction(style: .normal, title: "Uncheck") {(_, _, completionHandler) in
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
                guard let destinationController = segue.destination as? RestaurantDetailViewController else {
                    return
                }
                guard let safeSearchController = searchController else {
                    return
                }
                destinationController.restaurant = (safeSearchController.isActive) ? searchResults[indexPath.row]
                                                                               : restaurants[indexPath.row]
            }
        }
    }
}

    // MARK: - NSFetchedResultsControllerDelegate methods

extension RestaurantTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        default:
                tableView.reloadData()
        }
        if let fetchedObjects = controller.fetchedObjects {
            if let safeRestaurants = fetchedObjects as? [RestaurantMO] {
                restaurants = safeRestaurants
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}

    // MARK: - Search Controller methods

extension RestaurantTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            tableView.reloadData()
        }
    }
    
}
