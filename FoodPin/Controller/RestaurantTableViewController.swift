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
                    FoodPin.Color.myRed.uiColor,
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
        safeSearchController.obscuresBackgroundDuringPresentation = false
        
        self.searchController?.searchBar.delegate = self
        safeSearchController.searchBar.placeholder = "Search restaurants..."
        safeSearchController.searchBar.barTintColor = .white
        safeSearchController.searchBar.backgroundImage = UIImage()
        safeSearchController.searchBar.tintColor = FoodPin.Color.myRed.uiColor
        
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
            fetchAllEntries()
        }
    }
    
    func fetchAllEntries() {
        do {
            try fetchResultController.performFetch()
            if let fetchedObjects = fetchResultController.fetchedObjects {
                restaurants = fetchedObjects
            }
        } catch {
            print(error)
        }
    }
    
    func filterContent(for searchText: String) {
        var predicate: NSPredicate = NSPredicate()
        predicate = NSPredicate(format: "(name contains [cd] %@)", searchText)
        fetchResultController.fetchRequest.predicate = predicate
        do {
            try fetchResultController.performFetch()
            if let fetchedObjects = fetchResultController.fetchedObjects {
                restaurants = fetchedObjects
            }
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.barStyle = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
            return
        }
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let walkthroughViewController = storyboard.instantiateViewController(identifier: "WalkthroughViewController")
            as? WalkthroughViewController {
            present(walkthroughViewController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {}
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let safeSearchController = searchController else {
            return 1
        }
        
        if !restaurants.isEmpty || safeSearchController.isActive {
            tableView.backgroundView?.isHidden = true
            tableView.separatorStyle = .singleLine
        } else {
            tableView.backgroundView?.isHidden = false
            tableView.separatorStyle = .none
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
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
    
        let restaurant = restaurants[indexPath.row]
        
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
        
        deleteAction.backgroundColor = FoodPin.Color.myRed.uiColor
        deleteAction.image = UIImage(systemName: "trash")
        shareAction.backgroundColor = FoodPin.Color.myOrange.uiColor
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
                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                    appDelegate.saveContext()
                }
            }
            completionHandler(true)
        }
        
        let uncheckAction = UIContextualAction(style: .normal, title: "Uncheck") {(_, _, completionHandler) in
            if let safeCell = tableView.cellForRow(at: indexPath) as? RestaurantTableViewCell {
                safeCell.checkmarkImage.isHidden = true
                self.restaurants[indexPath.row].isVisited = false
                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                    appDelegate.saveContext()
                }
            }
            completionHandler(true)
        }
        
        checkInAction.backgroundColor = FoodPin.Color.myGreen.uiColor
        checkInAction.image = UIImage(systemName: "checkmark")
        uncheckAction.backgroundColor = FoodPin.Color.myGreen.uiColor
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
                destinationController.restaurant = restaurants[indexPath.row]
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

    // MARK: - UISearchBarDelegate methods

extension RestaurantTableViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        fetchResultController.fetchRequest.predicate = NSPredicate(value: true)
        fetchAllEntries()
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchController?.searchBar.text {
            if !searchText.isEmpty {
                filterContent(for: searchText)
            } else {
                restaurants = []
            }
            tableView.reloadData()
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        guard let safeSearchController = searchController,
              let searchText = searchBar.text else {
            return true
        }
        
        if !searchText.isEmpty {
            filterContent(for: searchText)
        } else {
            safeSearchController.isActive = true
            restaurants = []
        }
        
        tableView.reloadData()
        return true
    }
    
}
