//
//  ParkingTabTableViewController.swift
//  capstoneParking
//
//  Created by Justin Snider on 3/22/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

class ParkingTabViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    var defaultReservedSectionHeight: CGFloat = 180
    var defaultRegisteredCellHeight: CGFloat?
    
    var currentRegisteredSpot: RegisteredSpot?
    var currentReservation: Reservation?
    var currentRegisteredSpotImage: UIImage?
    var currentReservationImage: UIImage?
    var reservations: [Reservation]?
    
    //========================================
    //MARK: - IBOutlets
    //========================================
    
    @IBOutlet weak var parkingTableView: UITableView!
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let currentUser = UserController.shared.getCurrentUser() else { return }
        
        if currentUser.registeredSpots.count < 1 {
            defaultRegisteredCellHeight = parkingTableView.bounds.height - defaultReservedSectionHeight
        }
        
        parkingTableView.reloadData()
    }

    //========================================
    //MARK: - Table View Delegate and Data Source
    //========================================

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Reservations"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentUser = UserController.shared.getCurrentUser() else { return }
        
        if indexPath.section == 0 {
            currentReservation = currentUser.reservations[indexPath.row]
            currentReservationImage = UserController.shared.getReservedSpotImages()[indexPath.row]
            
            performSegue(withIdentifier: "reservedSegue", sender: nil)
        } else if indexPath.section == 1 {
            currentRegisteredSpot = currentUser.registeredSpots[indexPath.row]
            currentRegisteredSpotImage = UserController.shared.getRegisteredSpotImages()[indexPath.row]
            
            performSegue(withIdentifier: "registeredSegue", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1:
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40))
            let label = UILabel(frame: CGRect(x: 15, y: 10, width: 150, height: 21))
            let button = UIButton(frame: CGRect(x: CGFloat(view.frame.width - 40), y: 0, width: 40, height: 40))
            
            view.backgroundColor = #colorLiteral(red: 0.9691255689, green: 0.9698591828, blue: 0.9692392945, alpha: 1)
            
            label.text = "Registered Spots"
            label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            
            button.setImage(UIImage(named: "Add"), for: .normal)
            
            button.addTarget(self, action: #selector(registerSpotButtonTapped), for: .touchUpInside)
            
            view.addSubview(button)
            view.addSubview(label)
            
            return view
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let currentUser = UserController.shared.getCurrentUser() else { return CGFloat(70) }
        
        switch indexPath.section {
        case 0:
            
            if indexPath.row == 0 && currentUser.reservations.count < 1 {
                return CGFloat(100)
            }
        case 1:
            //Using a property inside of the controller because if a user were to swipe up too quickly this function gets recalled and the height of parkingTableView
            if indexPath.row == 0 && currentUser.registeredSpots.count < 1 {
                //Returns the same value that DefaultRegisteredCellHeight gets set to either way because the first unwrapping of cell height is always nil.
                guard let cellHeight = defaultRegisteredCellHeight else { return parkingTableView.bounds.height - defaultReservedSectionHeight }
                return cellHeight
            }
            
        default:
            break
        }
        return CGFloat(70)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let currentUser = UserController.shared.getCurrentUser() else { return 1 }
        
        switch section {
        case 0:
            if currentUser.reservations.count < 1 {
                return 1
            } else {
                return currentUser.reservations.count
            }
        case 1:
            if currentUser.registeredSpots.count < 1 {
                return 1
            } else {
                return currentUser.registeredSpots.count
            }
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        guard let currentUser = UserController.shared.getCurrentUser() else { return UITableViewCell()}
        
        if indexPath.section == 0 {
            
            if currentUser.reservations.count < 1 {
                cell = UITableViewCell()
                cell.backgroundColor = #colorLiteral(red: 0.6666069031, green: 0.6667048335, blue: 0.6665855646, alpha: 1)
                cell.textLabel?.numberOfLines = 0

                cell.textLabel?.text = "If you'd like to make a reservation, tap on any pin you find in the area you want to reserve."
                cell.textLabel?.textAlignment = .center
                
                cell.isUserInteractionEnabled = false
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "reservedIdentifier", for: indexPath)
                
                let reservedSpotImages = UserController.shared.getReservedSpotImages()
                
                cell.imageView?.image = reservedSpotImages[indexPath.row]
                
                cell.textLabel?.text = currentUser.reservations[indexPath.row].reservedSpot.address
                cell.detailTextLabel?.text = currentUser.reservations[indexPath.row].time
                
            }
        } else {
            if currentUser.registeredSpots.count < 1 {
                cell = UITableViewCell()
                cell.backgroundColor = #colorLiteral(red: 0.6666069031, green: 0.6667048335, blue: 0.6665855646, alpha: 1)
                cell.textLabel?.numberOfLines = 0
                
                cell.textLabel?.text = "Tap and hold on the map to place a pin and register your spot or press the blue add button on the top right."
                cell.textLabel?.textAlignment = .center
                
                cell.isUserInteractionEnabled = false
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "registeredIdentifier", for: indexPath)
                
                let registeredSpotImages = UserController.shared.getRegisteredSpotImages()
                
                cell.imageView?.image = registeredSpotImages[indexPath.row]
                
                cell.textLabel?.text = currentUser.registeredSpots[indexPath.row].address
                cell.detailTextLabel?.text = "Number of spaces: \(currentUser.registeredSpots[indexPath.row].numberOfSpaces)"
            }
        }

        // Configure the cell...

        return cell
    }
    
    //========================================
    //MARK: - Navigation
    //========================================
    
    @objc func registerSpotButtonTapped() {
        performSegue(withIdentifier: "registerSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let destination = segue.destination as? RegisteredSpotDetailViewController {
            destination.currentRegisteredSpot = currentRegisteredSpot
            destination.currentRegisteredSpotImage = currentRegisteredSpotImage
            destination.reservations = reservations
        } else if let destination = segue.destination as? ReservedSpotDetailViewController {
            destination.currentReservation = currentReservation
            destination.currentReservationImage = currentReservationImage
        }
    }

}
