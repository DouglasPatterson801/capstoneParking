//
//  DetailViewController.swift
//  capstoneParking
//
//  Created by Justin Snider on 3/22/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

protocol NavigationButtonDelegate {
    func cancelButtonTapped(sender: UIBarButtonItem)
}

class RegistrationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NavigationButtonDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    //========================================
    //MARK: - Properties
    //========================================
    
    var currentTimeButton: UIButton?
    private var availableHours: [String : [String]] = [:]
    
    //State Picker Properties
    let statePickerData: [String] = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "Washington D.C.", "West Virginia", "Wisconsin", "Wyoming"]
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statePickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statePickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        stateTextField.text = statePickerData[row]
    }
    
    //========================================
    //MARK: - IBOutlets
    //========================================
    
    //Address Text fields
    @IBOutlet weak var addressTitleLabel: UILabel!
    @IBOutlet weak var streetAddressTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    
    @IBOutlet weak var spacesTitleLabel: UILabel!
    @IBOutlet weak var spacesTextField: UITextField!
    
    @IBOutlet weak var rateTitleLabel: UILabel!
    @IBOutlet weak var rateTextField: UITextField!
    
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    
    //Available hours buttons for simple selection
    @IBOutlet weak var fromTimeButton: UIButton!
    @IBOutlet weak var toTimeButton: UIButton!
    @IBOutlet weak var availableDaysSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var spotImageView: UIImageView!
    
    //Available hours labels
    @IBOutlet weak var availabilityTitleLabel: UILabel!
    @IBOutlet weak var fromTimeLabel: UILabel!
    @IBOutlet weak var toTimeLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    
    @IBOutlet weak var parkingInstructionsTitleLabel: UILabel!
    @IBOutlet weak var parkingInstructionsTextView: CustomTextView!
    
    //Picking time for available hours
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var timePickerView: UIView!
    @IBOutlet weak var timePickerViewHeightConstraint: NSLayoutConstraint!
    
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
                self.viewHeightConstraint.constant = 1500
                
                self.view.layoutIfNeeded()
            }
        } else {
            //Setting up current time button
            currentTimeButton?.isSelected = false
            currentTimeButton = nil
            
            //Animate view size and time picker size
            UIView.animate(withDuration: 0.5) {
                self.timePickerViewHeightConstraint.constant = 0
                self.viewHeightConstraint.constant = 1300
                
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
    
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        guard let image = spotImageView.image else { return }
        
        UserController.shared.addRegisteredSpotImage(image)
        FirebaseController.shared.addImageToStorage(image)
        
        if let imageURLString = UserController.shared.getCurrentRegisteredSpotImageURL()?.absoluteString,
           let numberOfSpaces = Int(spacesTextField.text ?? ""),
           let rate = Double(rateTextField.text ?? "") {
            let address = "\(streetAddressTextField.text ?? ""), \(cityTextField.text ?? ""), \(stateTextField.text ?? "") \(zipCodeTextField.text ?? "")"
            let parkingInstructions = parkingInstructionsTextView.text ?? ""
            
            let newRegisteredSpot = RegisteredSpot(imageURLString: imageURLString, address: address, numberOfSpaces: numberOfSpaces, rate: rate, parkingInstructions: parkingInstructions, availableHours: availableHours, coordinates: nil)
            
            let group = DispatchGroup()
            
            group.enter()
            UserController.shared.addRegisteredSpot(newRegisteredSpot) { group.leave() }
            group.wait()
            
            guard let currentUser = UserController.shared.getCurrentUser() else { return }
            
            FirebaseController.shared.updateUser(currentUser)
            self.navigationController?.popViewController(animated: true)
        }
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
        self.hideKeyboardWhenTappedAround()
        let pickerView = UIPickerView()
        pickerView.delegate = self
        stateTextField.inputView = pickerView
        
        timePickerViewHeightConstraint.constant = 0
        
        timePickerView.clipsToBounds = true
        
        parkingInstructionsTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        viewHeightConstraint.constant = 1300
        
        updateAvailableHours(customAvailableHours: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        spacesTextField.addBorder(side: .Bottom, thickness: 3, color: UIColor.gray, leftOffset: 0, rightOffset: 0, topOffset: 0, bottomOffset: -2)
        
        rateTextField.addBorder(side: .Bottom, thickness: 3, color: UIColor.gray, leftOffset: 0, rightOffset: 0, topOffset: 0, bottomOffset: -2)
        
        streetAddressTextField.addBorder(side: .Bottom, thickness: 3, color: UIColor.gray, leftOffset: 0, rightOffset: 0, topOffset: 0, bottomOffset: -2)
        
        stateTextField.addBorder(side: .Bottom, thickness: 3, color: UIColor.gray, leftOffset: 0, rightOffset: 0, topOffset: 0, bottomOffset: -2)
        
        cityTextField.addBorder(side: .Bottom, thickness: 3, color: UIColor.gray, leftOffset: 0, rightOffset: 0, topOffset: 0, bottomOffset: -2)
        
        zipCodeTextField.addBorder(side: .Bottom, thickness: 3, color: UIColor.gray, leftOffset: 0, rightOffset: 0, topOffset: 0, bottomOffset: -2)
        
        addressTitleLabel.font = UIFont.boldSystemFont(ofSize: 26)
        
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
