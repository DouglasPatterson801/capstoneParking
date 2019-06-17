//
//  RegisteredSpotDetailViewController.swift
//  capstoneParking
//
//  Created by Justin Snider on 5/12/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

class RegisteredSpotDetailViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NavigationButtonDelegate {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    var currentRegisteredSpot: RegisteredSpot?
    var currentRegisteredSpotImage: UIImage?
    
    var currentTimeButton: UIButton?
    private var availableHours: [String : [String]] = [:]
    
    var reservations: [Reservation]?
    
    //========================================
    //MARK: - IBOutlets
    //========================================
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var spacesTitleLabel: UILabel!
    @IBOutlet weak var spacesTextField: UITextField!
    @IBOutlet weak var rateTitleLabel: UILabel!
    @IBOutlet weak var rateTextField: UITextField!
    @IBOutlet weak var parkingInstructionsTitleLabel: UILabel!
    @IBOutlet weak var parkingInstructionsTextView: CustomTextView!
    @IBOutlet weak var availabilityTitleLabel: UILabel!
    @IBOutlet weak var spotImageView: UIImageView!
    
    //Available hours buttons for simple selection
    @IBOutlet weak var fromTimeButton: UIButton!
    @IBOutlet weak var toTimeButton: UIButton!
    @IBOutlet weak var availableDaysSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var fromTimeLabel: UILabel!
    @IBOutlet weak var toTimeLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    
    //Picking time for available hours
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var timePickerView: UIView!
    @IBOutlet weak var timePickerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    
    //========================================
    //MARK: - IBActions
    //========================================
    
    @IBAction func timeButtonTapped(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        
        if currentTimeButton != sender {
            //Setting up current time button
            if currentTimeButton != nil {
                currentTimeButton?.isSelected = false
            }
            currentTimeButton = sender
            currentTimeButton?.isSelected = true
            
            //Setting up From and To time pickers
            if sender == fromTimeButton, let time = dateFormatter.date(from: fromTimeLabel.text ?? "") {
                timePicker.date = time
            } else if sender == toTimeButton, let time = dateFormatter.date(from: toTimeLabel.text ?? "") {
                timePicker.date = time
            }
            
            //Animate view size and time picker size
            UIView.animate(withDuration: 0.5) {
                self.timePickerViewHeightConstraint.constant = 216
                self.viewHeightConstraint.constant = 1350
                
                self.view.layoutIfNeeded()
            }
        } else {
            //Setting up current time button
            currentTimeButton?.isSelected = false
            currentTimeButton = nil
            
            //Animate view size and time picker size
            UIView.animate(withDuration: 0.5) {
                self.timePickerViewHeightConstraint.constant = 0
                self.viewHeightConstraint.constant = 1150
                
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func timePickerChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        //Sets From and To labels based on time picker value
        if currentTimeButton == fromTimeButton {
            fromTimeLabel.text = dateFormatter.string(from: sender.date)
        } else if currentTimeButton == toTimeButton {
            toTimeLabel.text = dateFormatter.string(from: sender.date)
        }
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 3 {
            performSegue(withIdentifier: "availableHoursSegue", sender: sender)
        } else {
            updateAvailableHours(customAvailableHours: nil)
        }
        
        //Reset buttons and labels
        fromLabel.textColor = UIColor.black
        toLabel.textColor = UIColor.black
        fromTimeLabel.textColor = UIColor.black
        toTimeLabel.textColor = UIColor.black
        fromTimeButton.tintColor = UIColor.black
        toTimeButton.tintColor = UIColor.black
        
        fromTimeButton.isEnabled = true
        toTimeButton.isEnabled = true
    }
    
    @IBAction func selectSpotImageView(_ sender: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func updateRegisteredSpot(_ sender: Any) {
        
        if let image = spotImageView.image, currentRegisteredSpotImage != spotImageView.image {
            FirebaseController.shared.addImageToStorage(image)
            
            guard let imageURLString = UserController.shared.getCurrentRegisteredSpotImageURL()?.absoluteString else { return }
            
            currentRegisteredSpot?.imageURLString = imageURLString
        }
        
        currentRegisteredSpot?.address = addressLabel.text ?? ""
        currentRegisteredSpot?.availableHours = availableHours
        currentRegisteredSpot?.rate = Double(rateTextField.text ?? "")!
        currentRegisteredSpot?.numberOfSpaces = Int(spacesTextField.text ?? "")!
        currentRegisteredSpot?.parkingInstructions = parkingInstructionsTextView.text
        
        UserController.shared.replaceRegisteredSpot(with: currentRegisteredSpot!)
        
        guard let currentUser = UserController.shared.getCurrentUser() else { return }
        
        FirebaseController.shared.updateUser(currentUser)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteRegisteredSpot(_ sender: Any) {
        if reservations != nil {
            for i in 0...reservations!.count - 1 {
                if reservations?[i].reservedSpot.address == currentRegisteredSpot?.address {
                    FirebaseController.shared.fetchUser(for: reservations![i].userEmail) { (user) in
                        if user != nil {
                            var user = user
                            for j in 0...user!.reservations.count - 1 {
                                if self.reservations![i].reservationID == user!.reservations[j].reservationID {
                                    user!.reservations.remove(at: j)
                                }
                            }
                            FirebaseController.shared.updateUser(user)
                        }
                    }
                }
            }
        }
        UserController.shared.removeRegisteredSpot(currentRegisteredSpot!)
        FirebaseController.shared.updateUser(UserController.shared.getCurrentUser())
        navigationController?.popViewController(animated: true)
    }
    
    
    //========================================
    //MARK: - Text Field Delegate Methods
    //========================================
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //========================================
    //MARK: - Image Picker Delegate Methods
    //========================================
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            spotImageView.image = selectedImage
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //========================================
    //MARK: - Navigation Delegate Methods
    //========================================
    
    func cancelButtonTapped(sender: UIBarButtonItem) {
        availableDaysSegmentedControl.selectedSegmentIndex = 0
    }
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentRegisteredSpot = currentRegisteredSpot else { fatalError() }
        
        spotImageView.image = currentRegisteredSpotImage
        
        addressLabel.text = "\(currentRegisteredSpot.address)"
        addressLabel.adjustsFontSizeToFitWidth = true
        
        spacesTextField.delegate = self
        spacesTextField.becomeFirstResponder()
        spacesTextField.text = "\(currentRegisteredSpot.numberOfSpaces)"
        
        rateTextField.text = "\(currentRegisteredSpot.rate)"
        
        parkingInstructionsTextView.text = "\(currentRegisteredSpot.parkingInstructions)"
        
        timePickerViewHeightConstraint.constant = 0
        
        timePickerView.clipsToBounds = true
        
        parkingInstructionsTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        viewHeightConstraint.constant = 1150
        
        updateAvailableHours(customAvailableHours: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        spacesTextField.addBorder(side: .Bottom, thickness: 3, color: UIColor.gray, leftOffset: 0, rightOffset: 0, topOffset: 0, bottomOffset: -2)
        
        rateTextField.addBorder(side: .Bottom, thickness: 3, color: UIColor.gray, leftOffset: 0, rightOffset: 0, topOffset: 0, bottomOffset: -2)
        
        addressLabel.font = UIFont.boldSystemFont(ofSize: 26)
        addressLabel.addBorder(side: .Bottom, thickness: 2, color: UIColor.lightGray, leftOffset: 159.5, rightOffset: 159.5, topOffset: 0, bottomOffset: -6)
        
        spacesTitleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        rateTitleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        availabilityTitleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        parkingInstructionsTitleLabel.font = UIFont.boldSystemFont(ofSize: 24)
    }
    
    //========================================
    //MARK: - Navigation
    //========================================
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let destination = segue.destination as? AvailableHoursViewController {
            destination.delegate = self
        }
    }
    
    @IBAction func unwindToDetailViewController(segue: UIStoryboardSegue) {
        fromLabel.textColor = UIColor.lightGray
        toLabel.textColor = UIColor.lightGray
        fromTimeLabel.textColor = UIColor.lightGray
        toTimeLabel.textColor = UIColor.lightGray
        fromTimeButton.tintColor = UIColor.lightGray
        toTimeButton.tintColor = UIColor.lightGray
        
        fromTimeButton.isEnabled = false
        toTimeButton.isEnabled = false
    }
    
    //========================================
    //MARK: - Helper methods
    //========================================
    
    func updateAvailableHours(customAvailableHours: [String : [String]]?) {
        switch availableDaysSegmentedControl.selectedSegmentIndex {
        case 0:
            availableHours = [
                "Monday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Tuesday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Wednesday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Thursday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Friday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Saturday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Sunday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""]
            ]
        case 1:
            availableHours = [
                "Monday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Tuesday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Wednesday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Thursday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Friday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Saturday" : ["Unavailable"],
                "Sunday" : ["Unavailable"]
            ]
        case 2:
            availableHours = [
                "Monday" : ["Unavailable"],
                "Tuesday" : ["Unavailable"],
                "Wednesday" : ["Unavailable"],
                "Thursday" : ["Unavailable"],
                "Friday" : ["Unavailable"],
                "Saturday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""],
                "Sunday" : [fromTimeLabel.text ?? "", toTimeLabel.text ?? ""]
            ]
        case 3:
            guard let customAvailableHours = customAvailableHours else { return }
            availableHours = customAvailableHours
        default:
            break
        }
    }
    
}
