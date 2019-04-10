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

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
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
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
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
        
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
        
        mapView.showsUserLocation = true
        customAlertControllerStackview.transform = CGAffineTransform(translationX: 0, y: 210)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        registerSpotUIView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
        registerUIView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10.0)
    }
    
    //==================================================
    // MARK: - Functions
    //==================================================
    
    
    func setInitialMapProperties() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
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
    
    func beginNavigation() {
        guard let sourceCoordinate = locationManager.location?.coordinate,
            let destination = mapView.annotations.first else { return }
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destination.coordinate)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceItem
        directionRequest.destination = destinationItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: { response, error in
            guard let response = response else {
                if let error = error {
                    print("Error occured while calculating directions")
                }
                return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        })
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
//        let request = MKDirections.Request()
//        request.source = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoordinates))
//        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinate))
//        request.requestsAlternateRoutes = true
//        request.transportType = .automobile
//
//        let directions = MKDirections(request: request)
//
//        directions.calculate { [unowned self] response, error in
//            guard let unwrappedResponse = response else { return }
//
//            for route in unwrappedResponse.routes {
//                self.mapView.addOverlay(route.polyline)
//                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
//            }
//        }
//    }
//
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
//        return renderer
//    }
    
/*
     CUSTOM PIN
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customAnnotation")
        annotationView.image = UIImage(named: "pin")
        annotationView.canShowCallout = true
        return annotationView
    }
 */
    
    //==================================================
    // MARK: - Actions
    //==================================================
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.customAlertControllerStackview.transform = CGAffineTransform(translationX: 0, y: 210)
            self.mapView.alpha = 1.0
            self.backgroundUIView.backgroundColor = nil
            self.mapView.isUserInteractionEnabled = true
            self.beginNavigation()
//            self.mapView(mapView, rendererFor: mgit )
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.customAlertControllerStackview.transform = CGAffineTransform(translationX: 0, y: 210)
            self.mapView.alpha = 1.0
            self.backgroundUIView.backgroundColor = nil
        }
//        guard let newestAnnotation = mapView.annotations.last else { return }
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.isUserInteractionEnabled = true
    }
    
    @IBAction func userDidLongPress(_ sender: UILongPressGestureRecognizer) {
        UIView.animate(withDuration: 0.3) {
            self.customAlertControllerStackview.transform = CGAffineTransform(translationX: 0, y: 0)
            self.mapView.alpha = 0.6
            self.backgroundUIView.backgroundColor = #colorLiteral(red: 0.6059342617, green: 0.6059342617, blue: 0.6059342617, alpha: 1)
        }
        
        let location = sender.location(in: self.mapView)
        let locationCoordinate = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        annotation.title = "New Parking Spot"
        
//        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.addAnnotation(annotation)
        self.mapView.isUserInteractionEnabled = false
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
