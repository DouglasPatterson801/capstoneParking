//
//  AvailableHoursViewController.swift
//  capstoneParking
//
//  Created by Justin Snider on 4/22/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

class AvailableHoursViewController: UIViewController {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    var delegate: NavigationButtonDelegate?
    var currentTimeButton: UIButton?
    var currentSegmentedControl: UISegmentedControl?
    
    //========================================
    //MARK: - IBOutlets
    //========================================
    
    @IBOutlet weak var fromTimeButton: UIButton!
    @IBOutlet weak var toTimeButton: UIButton!
    
    @IBOutlet weak var fromTimeLabel: UILabel!
    @IBOutlet weak var toTimeLabel: UILabel!
    
    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBOutlet weak var firstFourDaySegmentedControl: UISegmentedControl!
    @IBOutlet weak var lastThreeDaySegmentedControl: UISegmentedControl!
    
    //Day label outlets
    @IBOutlet weak var mondayFromTimeLabel: UILabel!
    @IBOutlet weak var mondayToTimeLabel: UILabel!
    @IBOutlet weak var tuesdayFromTimeLabel: UILabel!
    @IBOutlet weak var tuesdayToTimeLabel: UILabel!
    @IBOutlet weak var wednesdayFromTimeLabel: UILabel!
    @IBOutlet weak var wednesdayToTimeLabel: UILabel!
    @IBOutlet weak var thursdayFromTimeLabel: UILabel!
    @IBOutlet weak var thursdayToTimeLabel: UILabel!
    @IBOutlet weak var fridayFromTimeLabel: UILabel!
    @IBOutlet weak var fridayToTimeLabel: UILabel!
    @IBOutlet weak var saturdayFromTimeLabel: UILabel!
    @IBOutlet weak var saturdayToTimeLabel: UILabel!
    @IBOutlet weak var sundayFromTimeLabel: UILabel!
    @IBOutlet weak var sundayToTimeLabel: UILabel!
    
    //========================================
    //MARK: - IBActions
    //========================================
    
    @IBAction func timeButtonTapped(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        
        if currentTimeButton != sender {
            //Setting up current time button
            currentTimeButton?.isSelected = false
            currentTimeButton = sender
            currentTimeButton?.isSelected = true
            
            //Setting up From and To time pickers
            if sender == fromTimeButton, let time = dateFormatter.date(from: fromTimeLabel.text ?? "") {
                timePicker.date = time
            } else if sender == toTimeButton, let time = dateFormatter.date(from: toTimeLabel.text ?? "") {
                timePicker.date = time
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
        
        updateTime()
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender != currentSegmentedControl, let selectedSegmentIndex = currentSegmentedControl?.selectedSegmentIndex {
            //Unselects the currently selected segment if you select another segemented control
            currentSegmentedControl?.setEnabled(false, forSegmentAt: selectedSegmentIndex)
            currentSegmentedControl?.setEnabled(true, forSegmentAt: selectedSegmentIndex)
            
            currentSegmentedControl = sender
        }
        
        setTimeUp(sender)
    }
    
    
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"

        if let time = dateFormatter.date(from: fromTimeLabel.text ?? "") {
            timePicker.date = time
        }
        
        currentTimeButton = fromTimeButton
        
        currentSegmentedControl = firstFourDaySegmentedControl
    }
    
    //========================================
    //MARK: - Navigation
    //========================================
    
    @IBAction func barButtonTapped(_ sender: UIBarButtonItem) {
        delegate?.cancelButtonTapped(sender: sender)
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let destination = segue.destination as? RegistrationViewController {
            let availableHours = [
                "Monday" : ["\(mondayFromTimeLabel.text ?? "")", "\(mondayToTimeLabel.text ?? "")"],
                "Tuesday" : ["\(tuesdayFromTimeLabel.text ?? "")", "\(tuesdayToTimeLabel.text ?? "")"],
                "Wednesday" : ["\(wednesdayFromTimeLabel.text ?? "")", "\(wednesdayFromTimeLabel.text ?? "")"],
                "Thursday" : ["\(thursdayFromTimeLabel.text ?? "")", "\(thursdayToTimeLabel.text ?? "")"],
                "Friday" : ["\(fridayFromTimeLabel.text ?? "")", "\(fridayToTimeLabel.text ?? "")"],
                "Saturday" : ["\(saturdayFromTimeLabel.text ?? "")", "\(saturdayToTimeLabel.text ?? "")"],
                "Sunday" : ["\(sundayFromTimeLabel.text ?? "")", "\(sundayToTimeLabel.text ?? "")"]
            ]
            
            destination.updateAvailableHours(customAvailableHours: availableHours)
        }
    }
    
    //========================================
    //MARK: - Helper Methods
    //========================================
    
    private func setTimeUp(_ sender: UISegmentedControl) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        if sender == firstFourDaySegmentedControl {
            switch currentSegmentedControl?.selectedSegmentIndex {
            case 0:
                fromTimeLabel.text = mondayFromTimeLabel.text
                toTimeLabel.text = mondayToTimeLabel.text
            case 1:
                fromTimeLabel.text = tuesdayFromTimeLabel.text
                toTimeLabel.text = tuesdayToTimeLabel.text
            case 2:
                fromTimeLabel.text = wednesdayFromTimeLabel.text
                toTimeLabel.text = wednesdayToTimeLabel.text
            case 3:
                fromTimeLabel.text = thursdayFromTimeLabel.text
                toTimeLabel.text = thursdayToTimeLabel.text
            default:
                break
            }
        } else {
            switch currentSegmentedControl?.selectedSegmentIndex {
            case 0:
                fromTimeLabel.text = fridayFromTimeLabel.text
                toTimeLabel.text = fridayToTimeLabel.text
            case 1:
                fromTimeLabel.text = saturdayFromTimeLabel.text
                toTimeLabel.text = saturdayToTimeLabel.text
            case 2:
                fromTimeLabel.text = sundayFromTimeLabel.text
                toTimeLabel.text = sundayToTimeLabel.text
            default:
                break
            }
        }
        
        if currentTimeButton == fromTimeButton, let time = dateFormatter.date(from: fromTimeLabel.text ?? "") {
            timePicker.date = time
        } else if let time = dateFormatter.date(from: toTimeLabel.text ?? "") {
            timePicker.date = time
        }
    }
    
    private func updateTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        if currentTimeButton == fromTimeButton && currentSegmentedControl == firstFourDaySegmentedControl {
            switch currentSegmentedControl?.selectedSegmentIndex {
            case 0:
                mondayFromTimeLabel.text = dateFormatter.string(from: timePicker.date)
            case 1:
                tuesdayFromTimeLabel.text = dateFormatter.string(from: timePicker.date)
            case 2:
                wednesdayFromTimeLabel.text = dateFormatter.string(from: timePicker.date)
            case 3:
                thursdayFromTimeLabel.text = dateFormatter.string(from: timePicker.date)
            default:
                break
            }
        } else if currentTimeButton == toTimeButton && currentSegmentedControl == firstFourDaySegmentedControl {
            switch currentSegmentedControl?.selectedSegmentIndex {
            case 0:
                mondayToTimeLabel.text = dateFormatter.string(from: timePicker.date)
            case 1:
                tuesdayToTimeLabel.text = dateFormatter.string(from: timePicker.date)
            case 2:
                wednesdayToTimeLabel.text = dateFormatter.string(from: timePicker.date)
            case 3:
                thursdayToTimeLabel.text = dateFormatter.string(from: timePicker.date)
            default:
                break
            }
        } else if currentTimeButton == fromTimeButton && currentSegmentedControl == lastThreeDaySegmentedControl {
            switch currentSegmentedControl?.selectedSegmentIndex {
            case 0:
                fridayFromTimeLabel.text = dateFormatter.string(from: timePicker.date)
            case 1:
                saturdayFromTimeLabel.text = dateFormatter.string(from: timePicker.date)
            case 2:
                sundayFromTimeLabel.text = dateFormatter.string(from: timePicker.date)
            default:
                break
            }
        } else if currentTimeButton == toTimeButton && currentSegmentedControl == lastThreeDaySegmentedControl {
            switch currentSegmentedControl?.selectedSegmentIndex {
            case 0:
                fridayToTimeLabel.text = dateFormatter.string(from: timePicker.date)
            case 1:
                saturdayToTimeLabel.text = dateFormatter.string(from: timePicker.date)
            case 2:
                sundayToTimeLabel.text = dateFormatter.string(from: timePicker.date)
            default:
                break
            }
        }
    }
    
}
