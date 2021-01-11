//
//  RestaurantDetailViewController.swift
//  FoodPin
//
//  Created by Laurentiu Ile on 09/12/2020.
//

import UIKit
import CoreData

class RestaurantDetailViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: RestaurantDetailHeaderView!
    
    var restaurant: RestaurantMO?
    
    // MARK: - View Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        navigationItem.largeTitleDisplayMode = .never
        tableView.dataSource = self
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .white
        tableView.contentInsetAdjustmentBehavior = .never
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.navigationBar.barStyle = .black
        
        headerView.nameLabel.text = restaurant?.name
        headerView.typeLabel.text = restaurant?.type
        
        guard let safeRestaurant = restaurant else {
            return
        }
        
        headerView.headerImageView.image = UIImage(data: (safeRestaurant.image ?? Data()) as Data)
        headerView.heartImageView.isHidden = safeRestaurant.isVisited ? false : true
        if let safeRating = safeRestaurant.rating {
            headerView.ratingImageView.image = UIImage(named: safeRating)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMap" {
            guard let destinationController = segue.destination as? MapViewController else {
                return
            }
            destinationController.restaurant = restaurant
        } else
        if segue.identifier == "showReview" {
            guard let destinationController = segue.destination as? ReviewViewController else {
                return 
            }
            destinationController.restaurant = restaurant
        }
    }
    
    @IBAction func close(segue: UIStoryboardSegue) {}
    
    @IBAction func rateRestaurant(segue: UIStoryboardSegue) {
       
        if let rating = segue.identifier {
            self.restaurant?.rating = rating
            self.headerView.ratingImageView.image = UIImage(named: rating)
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                appDelegate.saveContext()
            }
            
            let scaleTransform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
            self.headerView.ratingImageView.transform = scaleTransform
            self.headerView.ratingImageView.alpha = 0
            
            UIView.animate(withDuration: 0.4, delay: 0,
                           usingSpringWithDamping: 0.3, initialSpringVelocity: 0.7,
                           options: [], animations: {
                            self.headerView.ratingImageView.transform = .identity
                            self.headerView.ratingImageView.alpha = 1
                           }, completion: nil)
        }
    }
    
}

// MARK: - Table View Delegate

extension RestaurantDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RestaurantDetailIconTextCell.self),
                for: indexPath) as? RestaurantDetailIconTextCell
            
            guard let safeCell = cell else {
                return UITableViewCell()
            }
            safeCell.iconImageView.image = UIImage(systemName: "phone")?
                .withTintColor(.black, renderingMode: .alwaysOriginal)
            guard let restaurantPhone = restaurant?.phone else {
                return UITableViewCell()
            }
            safeCell.shortTextLabel.text = restaurantPhone
            safeCell.selectionStyle = .none
            return safeCell
            
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RestaurantDetailIconTextCell.self),
                for: indexPath) as? RestaurantDetailIconTextCell
            
            guard let safeCell = cell else {
                return UITableViewCell()
            }
            safeCell.iconImageView.image = UIImage(systemName: "map")?
                .withTintColor(.black, renderingMode: .alwaysOriginal)
            guard let restaurantLocation = restaurant?.location else {
                return UITableViewCell()
            }
            safeCell.shortTextLabel.text = restaurantLocation
            safeCell.selectionStyle = .none
            return safeCell
            
        case 2:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RestaurantDetailTextCell.self),
                for: indexPath) as? RestaurantDetailTextCell
            
            guard let safeCell = cell else {
                return UITableViewCell()
            }
            guard let restaurantDescription = restaurant?.summary else {
                return UITableViewCell()
            }
            safeCell.descriptionLabel.text = restaurantDescription
            safeCell.selectionStyle = .none
            return safeCell
            
        case 3:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RestaurantDetailSeparatorCell.self),
                for: indexPath) as? RestaurantDetailSeparatorCell
            guard let safeCell = cell else {
                return UITableViewCell()
            }
            safeCell.titleLabel.text = "HOW TO GET THERE"
            safeCell.selectionStyle = .none
            return safeCell
            
        case 4:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RestaurantDetailMapCell.self),
                for: indexPath) as? RestaurantDetailMapCell
            guard let safeCell = cell else {
                return UITableViewCell()
            }
            guard let restaurantLocation = restaurant?.location else {
                return UITableViewCell()
            }
            safeCell.configure(location: restaurantLocation)
            return safeCell
            
        default:
            fatalError("Failed to instantiate the table view cell for detail view controller")
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
}
