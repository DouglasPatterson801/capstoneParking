//
//  MapViewController.swift
//  capstoneParking
//
//  Created by Justin Snider on 3/22/19.
//  Copyright © 2019 Justin Snider. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
}



class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil
    var registeredSpots: [RegisteredSpot]?
    var currentRegisteredSpot: RegisteredSpot?
    var reservations: [Reservation]?
    
    
    //Outlets
    @IBOutlet var backgroundUIView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var customAlertControllerStackview: UIStackView!
    @IBOutlet weak var registerSpotUIView: UIView!
    @IBOutlet weak var registerUIView: UIView!
    @IBOutlet weak var cancelUIView: UIView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    //==================================================
    // MARK: - View LifeCycle
    //==================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestAuthorizations()
        setInitialMapProperties()
        dropRegisteredSpotPins()
        
        if let parkingTabView = tabBarController?.viewControllers?[1] as? ParkingTabViewController {
            parkingTabView.reservations = reservations
        }
        
        let mapTabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Map"), selectedImage: UIImage(named: "Map Filled"))
        let parkingTabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Parking"), selectedImage: UIImage(named: "Parking Filled"))
        
        mapTabBarItem.imageInsets = UIEdgeInsets(top: 9, left: 0, bottom: -9, right: 0)
        parkingTabBarItem.imageInsets = UIEdgeInsets(top: 9, left: 0, bottom: -9, right: 0)
        
        tabBarController?.viewControllers?[1].tabBarItem = parkingTabBarItem
        tabBarController?.selectedViewController?.tabBarItem = mapTabBarItem
        
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
        
        customAlertControllerStackview.transform = CGAffineTransform(translationX: 0, y: 210)
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search desired area"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        registerSpotUIView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
        registerUIView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10.0)
    }
    
    //==================================================
    // MARK: - Functions - View and Layout
    //==================================================
    
    
    
    func showCustomAlertController() {
        UIView.animate(withDuration: 0.3) {
            self.customAlertControllerStackview.transform = CGAffineTransform(translationX: 0, y: 0)
            self.mapView.alpha = 0.6
            self.backgroundUIView.backgroundColor = #colorLiteral(red: 0.6059342617, green: 0.6059342617, blue: 0.6059342617, alpha: 1)
        }
        self.mapView.isUserInteractionEnabled = false
        
    }
    
    func hideCustomAlertController() {
        UIView.animate(withDuration: 0.3) {
            self.customAlertControllerStackview.transform = CGAffineTransform(translationX: 0, y: 210)
            self.mapView.alpha = 1.0
            self.backgroundUIView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        self.mapView.isUserInteractionEnabled = true
    }
    
    //==================================================
    // MARK: - Functions - MapKit
    //==================================================
    
    func requestAuthorizations() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
        }
    }
    
    func setInitialMapProperties() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        mapView.delegate = self
        mapView.showsScale = true
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        
        if let coordinate = mapView.userLocation.location?.coordinate {
            mapView.setCenter(coordinate, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        
        mapView.mapType = MKMapType.standard
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: locValue, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {            
            return nil
        }
        
        
        if let annotation = annotation as? SearchResultAnnotation {
            
            if annotation.isSearchResult == true {
                print("boolean found as true")
                return setSearchResultPin(annotation: annotation)
            } else {
                print("bool detected as false")
                return setRegisteredSpotPin(annotation: annotation)
            }
        } else if let annotation = annotation as? ParkingSpotAnnotation {
               return setRegisteredSpotPin(annotation: annotation)
        }
        return nil
        
    }
    
    func setRegisteredSpotPin(annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "spotPin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.glyphImage = UIImage(named: "carGlyph")
        pinView?.markerTintColor = #colorLiteral(red: 0.144528985, green: 0.6882172823, blue: 1, alpha: 1)
        pinView?.canShowCallout = true
        let square60 = CGSize(width: 60, height: 60)
        let point = CGPoint(x: 0, y: 0)
        
        let leftButton = UIButton(frame: CGRect(origin: point, size: square60))
        leftButton.imageEdgeInsets = UIEdgeInsets(top: -5, left: 5, bottom: 5, right: -5)
        leftButton.setImage(UIImage(named: "reserveButton"), for: .normal)
        leftButton.addTarget(self, action: #selector(reserveButtonTapped), for: .touchUpInside)
        
        pinView?.leftCalloutAccessoryView = leftButton
        
        pinView?.tag = 2
        
        return pinView
    }
    
    func setSearchResultPin(annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.red
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let point = CGPoint(x: 0, y: 0)
        let leftButton = UIButton(frame: CGRect(origin: point, size: smallSquare))
        leftButton.setBackgroundImage(UIImage(named: "go"), for: .normal)
        leftButton.addTarget(self, action: #selector(MapViewController.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = leftButton
        let rightButton = UIButton(frame: CGRect(origin: point, size: smallSquare))
        rightButton.setBackgroundImage(UIImage(named: "x"), for: .normal)
        rightButton.addTarget(self, action: #selector(MapViewController.removeSearchPin), for: .touchUpInside)
        pinView?.rightCalloutAccessoryView = rightButton
        pinView?.tag = 1
        
        return pinView
    }
    
    func getCoordinatesFor(address: String, completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void) {
        let geocoder = CLGeocoder()
//        guard let registeredSpots = registeredSpots else { return }
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?.first {
                    let location = placemark.location!
                    
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    
    
    
    @objc func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    @objc func removeSearchPin() {
        for annotation in mapView.annotations {
            let view = mapView.view(for: annotation)
            if view?.tag == 1 {
                mapView.removeAnnotation(annotation)
            }
        }
    }
    
    
    
    //==================================================
    // MARK: - Actions
    //==================================================
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        hideCustomAlertController()
        
        for annotation in mapView.annotations {
            if annotation.title == "New Parking Spot" {
                let newAnnotation = MKPointAnnotation()
                
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        hideCustomAlertController()
        
        for annotation in mapView.annotations {
            if annotation.title == "New Parking Spot" {
                mapView.removeAnnotation(annotation)
            }
        }
    }
    
    @IBAction func userDidLongPress(_ sender: UILongPressGestureRecognizer) {
        showCustomAlertController()
        
        let location = sender.location(in: self.mapView)
        let locationCoordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        annotation.title = "New Parking Spot"
        
        
        //        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        registeredSpots?.forEach({ (registeredSpot) in
            if registeredSpot.address == view.annotation?.title {
                currentRegisteredSpot = registeredSpot
            }
        })
    }
    
    func dropRegisteredSpotPins() {
        if registeredSpots != nil {
            for i in 0...registeredSpots!.count - 1 {
                let registeredSpot = registeredSpots![i]
                let annotation = MKPointAnnotation()
                if let registeredSpotCoordinates = registeredSpot.coordinates {
                    let parkingSpotAnnotation = ParkingSpotAnnotation(annotation: annotation, coordinate: registeredSpotCoordinates, title: registeredSpot.address, subtitle: "$\(registeredSpot.rate) per day.")
                    
                    annotation.coordinate = registeredSpotCoordinates
                    annotation.title = registeredSpot.address
                    mapView.addAnnotation(parkingSpotAnnotation)
                } else {
                    print("We don't have coordinates yet!")
               }

            }
            
        }
    }
    
    //========================================
    //MARK: - Navigation
    //========================================
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let destination = segue.destination as? ReservationViewController {
            destination.currentRegisteredSpot = currentRegisteredSpot
        }
    }
    
    @objc func reserveButtonTapped() {
        performSegue(withIdentifier: "reservationSegue", sender: nil)
    }
    
}

extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark) {
        // cache the pin
        selectedPin = placemark
        let annotation = MKPointAnnotation()
        let searchResultAnnotation = SearchResultAnnotation(annotation: annotation, searchResult: true, coordinate: placemark.coordinate, title: placemark.name, subtitle: nil)
        
        for annotation in mapView.annotations {
            let view = mapView.view(for: annotation)
            if view?.tag == 1 {
                mapView.removeAnnotation(annotation)
            }
        }
        
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        mapView.addAnnotation(searchResultAnnotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
}


extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}


