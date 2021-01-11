//
//  RestaurantTableViewController.swift
//  FoodPin
//
//  Created by Laurentiu Ile on 03/12/2020.
//

import UIKit
import CoreData
import UserNotifications

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
        prepareNotification()
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
    
    func prepareNotification() {
        
        if restaurants.isEmpty {
            return
        }
        
        let randomNum = Int.random(in: 0..<restaurants.count)
        let suggestedRestaurant = restaurants[randomNum]
        
        guard let suggestedName = suggestedRestaurant.name,
              let suggestedLocation = suggestedRestaurant.location else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Restaurant Recommendation"
        content.subtitle = "Try new food today"
        content.body = """
            I recommend you to check out \(suggestedName).
            The restaurant is one of your favorites. It is located at \(suggestedLocation).
            Would you like to give it a try?
            """
        content.sound = UNNotificationSound.default
        if let suggestedPhone = suggestedRestaurant.phone {
            content.userInfo = ["phone": suggestedPhone]
        }
        
        let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFileURL = tempDirURL.appendingPathComponent("suggested-restaurant.jpg")
        
        if let suggestedImage = suggestedRestaurant.image {
            if let image = UIImage(data: suggestedImage as Data) {
                try? image.jpegData(compressionQuality: 1.0)?.write(to: tempFileURL)
                if let restaurantImage = try? UNNotificationAttachment(identifier: "restaurantImage", url: tempFileURL, options: nil) {
                    content.attachments = [restaurantImage]
                }
            }
        }
        
        let categoryIdentifer = "foodpin.restaurantaction"
        let makeReservationAction = UNNotificationAction(identifier: "foodpin.makeReservation",
                                                         title: "Reserve a table",
                                                         options: [.foreground])
        let cancelAction = UNNotificationAction(identifier: "foodpin.cancel", title: "Later", options: [])
        let category = UNNotificationCategory(identifier: categoryIdentifer,
                                              actions: [makeReservationAction, cancelAction],
                                              intentIdentifiers: [],
                                              options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = categoryIdentifer
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "foodpin.restaurantSuggestion", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
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
                            contextMenuConfigurationForRowAt indexPath: IndexPath,
                            point: CGPoint) -> UIContextMenuConfiguration? {
        
        let configuration = UIContextMenuConfiguration(identifier: indexPath.row as NSCopying,
                                                       previewProvider: {
                        guard let restaurantDetailViewController =
                                self.storyboard?.instantiateViewController(
                                    identifier: "RestaurantDetailViewController")
                                as? RestaurantDetailViewController else {
                            return nil
                        }
                        let selectedRestaurant = self.restaurants[indexPath.row]
                        restaurantDetailViewController.restaurant = selectedRestaurant
                        
                        return restaurantDetailViewController
                       }, actionProvider: { _ in
                        
                        let checkInAction = UIAction(title: "Check-in", image: UIImage(systemName: "checkmark")) { _ in
                            let cell = tableView.cellForRow(at: indexPath) as? RestaurantTableViewCell
                            
                            guard let safeCell = cell else {
                                return
                            }
                            
                            self.restaurants[indexPath.row].isVisited = self.restaurants[indexPath.row].isVisited ? false : true
                            safeCell.checkmarkImage.isHidden = self.restaurants[indexPath.row] .isVisited ? false : true
                        }
                        
                        let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                            
                            guard let restaurantName = self.restaurants[indexPath.row].name else {
                                return
                            }
                            
                            let defaultText = NSLocalizedString("Just checking in at ", comment: "Just checking in at") + restaurantName
                            let activityController: UIActivityViewController
                            
                            if let restaurantImage = self.restaurants[indexPath.row].image,
                               let imageToShare = UIImage(data: restaurantImage as Data) {
                                activityController = UIActivityViewController(activityItems: [defaultText, imageToShare],
                                                                              applicationActivities: nil)
                            } else {
                                activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
                            }
                            self.present(activityController, animated: true, completion: nil)
                        }
                        
                        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                            
                            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                                let context = appDelegate.persistentContainer.viewContext
                                let restaurantToDelete = self.fetchResultController.object(at: indexPath)
                                context.delete(restaurantToDelete)
                                appDelegate.saveContext()
                            }
                        }
                        
                        return UIMenu(title: "", children: [checkInAction, shareAction, deleteAction])
                        
                       })
        return configuration
    }
    
    override func tableView(_ tableView: UITableView,
                            willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                            animator: UIContextMenuInteractionCommitAnimating) {
        
        guard let selectedRow = configuration.identifier as? Int else {
            print("Failed to retrieve the row number")
            return
        }
        
        guard let restaurantDetailViewController = self.storyboard?.instantiateViewController(
                withIdentifier: "RestaurantDetailViewController")
                as? RestaurantDetailViewController else {
            return
        }
        
        let selectedRestaurant = self.restaurants[selectedRow]
        restaurantDetailViewController.restaurant = selectedRestaurant
        
        animator.preferredCommitStyle = .pop
        animator.addCompletion {
            self.show(restaurantDetailViewController, sender: self)
        }
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
        
        let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") {(_, _, completionHandler) in
            self.restaurants[indexPath.row].favorite = true
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                appDelegate.saveContext()
            }
            completionHandler(true)
        }
        
        let unfavoriteAction = UIContextualAction(style: .normal, title: "Unfavorite") { (_, _, completionHandler) in
            self.restaurants[indexPath.row].favorite = false
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                appDelegate.saveContext()
            }
            completionHandler(true)
        }
        
        favoriteAction.backgroundColor = FoodPin.Color.myFavorite.uiColor
        favoriteAction.image = UIImage(systemName: "star")
        unfavoriteAction.backgroundColor = FoodPin.Color.myFavorite.uiColor
        unfavoriteAction.image = UIImage(systemName: "star.slash")
        
        var actions: [UIContextualAction] = []
        
        if let safeCell = tableView.cellForRow(at: indexPath) as? RestaurantTableViewCell {
            actions.append(safeCell.checkmarkImage.isHidden == false ? uncheckAction : checkInAction)
        }
        
        actions.append(restaurants[indexPath.row].favorite == true ? unfavoriteAction : favoriteAction)
        
        let swipeConfiguration: UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: actions)
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
