//
//  ReservedSpotViewController.swift
//  capstoneParking
//
//  Created by Justin Snider on 5/13/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit

class ReservedSpotDetailViewController: UIViewController {
    
    //========================================
    //MARK: - Properties
    //========================================
    
    var currentReservation: Reservation?
    var currentReservationImage: UIImage?
    
    //========================================
    //MARK: - IBOutlets
    //========================================
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var reservationImageView: UIImageView!
    
    //========================================
    //MARK: - IBActions
    //========================================
    
    @IBAction func removeReservationButtonTapped(_ sender: CustomButton) {
        guard let currentReservation = currentReservation else { return }
        UserController.shared.removeReserervedSpot(currentReservation)
        
        navigationController?.popViewController(animated: true)
    }
    
    //========================================
    //MARK: - Life Cycle Methods
    //========================================

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let currentReservation = currentReservation else { fatalError() }
        
        reservationImageView.image = currentReservationImage
        
        addressLabel.text = currentReservation.reservedSpot.address
        addressLabel.font = UIFont.boldSystemFont(ofSize: 26)
        addressLabel.adjustsFontSizeToFitWidth = true
        addressLabel.addBorder(side: .Bottom, thickness: 2, color: UIColor.lightGray, leftOffset: 159.5, rightOffset: 159.5, topOffset: 0, bottomOffset: -6)
        
        timeLabel.text = "\(currentReservation.time)"
    }

}
