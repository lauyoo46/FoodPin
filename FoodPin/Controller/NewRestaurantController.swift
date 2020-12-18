//
//  NewRestaurantController.swift
//  FoodPin
//
//  Created by Laurentiu Ile on 16/12/2020.
//

import UIKit
import CoreData

class NewRestaurantController: UITableViewController,
                               UIImagePickerControllerDelegate,
                               UINavigationControllerDelegate {
    
    var restaurant: RestaurantMO?
    
    @IBOutlet var photoImageView: UIImageView!
    
    @IBOutlet var nameTextField: RoundedTextField! {
        didSet {
            nameTextField.tag = 1
            nameTextField.becomeFirstResponder()
            nameTextField.delegate = self
        }
    }
    
    @IBOutlet var typeTextField: RoundedTextField! {
        didSet {
            typeTextField.tag = 2
            typeTextField.delegate = self
        }
    }
    
    @IBOutlet var addressTextField: RoundedTextField! {
        didSet {
            addressTextField.tag = 3
            addressTextField.delegate = self
        }
    }
    
    @IBOutlet var phoneTextField: RoundedTextField! {
        didSet {
            phoneTextField.tag = 4
            phoneTextField.delegate = self
        }
    }
    
    @IBOutlet var descriptionTextView: UITextView! {
        didSet {
            descriptionTextView.tag = 5
            descriptionTextView.layer.cornerRadius = 5.0
            descriptionTextView.layer.masksToBounds = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "Rubik-Medium", size: 35.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor:
                UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0),
                NSAttributedString.Key.font: customFont
            ]
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Oops", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let name = nameTextField.text {
            if name == "" {
                alert.message = "Name can not be blank"
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        if let type = typeTextField.text {
            if type == "" {
                alert.message = "Type can not be blank"
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        if let address = addressTextField.text {
            if address == "" {
                alert.message = "Address can not be blank"
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        if let phone = phoneTextField.text {
            if phone == "" {
                alert.message = "Phone can not be blank"
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        if let description = descriptionTextView.text {
            if description == "" {
                alert.message = "Description can not be blank"
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            restaurant = RestaurantMO(context: appDelegate.persistentContainer.viewContext)
            restaurant?.name = nameTextField.text
            restaurant?.type = typeTextField.text
            restaurant?.location = addressTextField.text
            restaurant?.phone = phoneTextField.text
            restaurant?.summary = descriptionTextView.text
            restaurant?.isVisited = false
            
            if let restaurantImage = photoImageView.image {
                restaurant?.image = restaurantImage.pngData()
            }
            
            appDelegate.saveContext()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let photoSourceRequestController = UIAlertController(title: "",
                                                                 message: "Choose your photo source",
                                                                 preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (_) in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .camera
                    self.present(imagePicker, animated: true, completion: nil) }
            })
            
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { (_) in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .photoLibrary
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
            
            photoSourceRequestController.addAction(cameraAction)
            photoSourceRequestController.addAction(photoLibraryAction)
            
            if let popoverController = photoSourceRequestController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
            
            present(photoSourceRequestController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Image Picker Controller Delegate
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photoImageView.image = selectedImage
            photoImageView.contentMode = .scaleAspectFill
            photoImageView.clipsToBounds = true
        }
        
        let leadingConstraint  = NSLayoutConstraint(item: photoImageView as Any ,
                                                    attribute: .leading,
                                                    relatedBy: .equal,
                                                    toItem: photoImageView.superview ,
                                                    attribute: .leading,
                                                    multiplier: 1,
                                                    constant: 0)
        leadingConstraint.isActive = true
        
        let trailingConstraint = NSLayoutConstraint(item: photoImageView as Any ,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: photoImageView.superview,
                                                    attribute: .trailing,
                                                    multiplier: 1,
                                                    constant: 0)
        trailingConstraint.isActive = true
        
        let topConstraint      = NSLayoutConstraint(item: photoImageView as Any,
                                                    attribute: .top,
                                                    relatedBy: .equal,
                                                    toItem: photoImageView.superview,
                                                    attribute: .top,
                                                    multiplier: 1,
                                                    constant: 0)
        topConstraint.isActive = true
        
        let bottomConstraint   = NSLayoutConstraint(item: photoImageView as Any,
                                                    attribute: .bottom,
                                                    relatedBy: .equal,
                                                    toItem: photoImageView.superview,
                                                    attribute: .bottom,
                                                    multiplier: 1,
                                                    constant: 0)
        bottomConstraint.isActive = true
        
        dismiss(animated: true, completion: nil)
        
    }
    
}

    // MARK: - Text field delegate

extension NewRestaurantController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}
