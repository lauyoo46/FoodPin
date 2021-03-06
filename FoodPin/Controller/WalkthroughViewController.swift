//
//  WalkthroughViewController.swift
//  FoodPin
//
//  Created by Laurentiu Ile on 21/12/2020.
//

import UIKit

class WalkthroughViewController: UIViewController {
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var nextButton: UIButton! {
        didSet {
            nextButton.layer.cornerRadius = 25.0
            nextButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var skipButton: UIButton!
    
    var walkthroughPageViewController: WalkthroughPageViewController?
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        
        UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
        dismiss(animated: true, completion: nil)
        createQuickActions()
        
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        
        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            case 0...1:
                walkthroughPageViewController?.forwardPage()
                
            case 2:
                UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
                createQuickActions()
                dismiss(animated: true, completion: nil)
                
            default: break
                
            }
        }
        updateUI()
        
    }
    
    func updateUI() {
        
        if let index = walkthroughPageViewController?.currentIndex {
            switch index {
            case 0...1:
                nextButton.setTitle("NEXT", for: .normal)
                skipButton.isHidden = false
                
            case 2:
                nextButton.setTitle("GET STARTED", for: .normal)
                skipButton.isHidden = true
                
            default: break
            }
            pageControl.currentPage = index
        }
        
    }
    
    func createQuickActions() {
        
        if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
            if let bundleIdentifier = Bundle.main.bundleIdentifier {
                
                let allRestaurantsShortcut = UIApplicationShortcutItem(type: "\(bundleIdentifier).OpenRestaurants",
                                                              localizedTitle: "Show Restaurants",
                                                              localizedSubtitle: nil,
                                                              icon: UIApplicationShortcutIcon(templateImageName: "favorite"),
                                                              userInfo: nil)
                let favoriteRestaurantsShortcut = UIApplicationShortcutItem(type: "\(bundleIdentifier).OpenFavorites",
                                                              localizedTitle: "Show Favorites",
                                                              localizedSubtitle: nil,
                                                              icon: UIApplicationShortcutIcon(templateImageName: "discover"),
                                                              userInfo: nil)
                let newRestaurantShortcut = UIApplicationShortcutItem(type: "\(bundleIdentifier).NewRestaurant",
                                                              localizedTitle: "New Restaurant",
                                                              localizedSubtitle: nil,
                                                              icon: UIApplicationShortcutIcon(type: .add),
                                                              userInfo: nil)
                UIApplication.shared.shortcutItems = [allRestaurantsShortcut, favoriteRestaurantsShortcut, newRestaurantShortcut]
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination
        if let pageViewController = destination as? WalkthroughPageViewController {
            walkthroughPageViewController = pageViewController
            walkthroughPageViewController?.walkthroughDelegate = self
        }
    }
    
}

    // MARK: - WalkthroughPageViewController methods

extension WalkthroughViewController: WalkthroughPageViewControllerDelegate {
    
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
    
}
