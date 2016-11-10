//
//  StopsViewController.swift
//  big-red-shuttle
//
//  Created by Kevin Greer on 10/12/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

class StopsViewController: UIViewController, GMSMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource{
    
    // MARK: Properties
    
    var mapView: GMSMapView!
    var panBounds: GMSCoordinateBounds!
    let kBoundPadding: CGFloat = 40
    let polyline = Polyline()
    let maxWayPoints = 8
    
    var currentMarker: GMSMarker!
    var popUpView = UIView()

    
    var longitude: Double!
    var latitude: Double!
    
    var stops: [Stop]!
    var selectedStop: Stop!
    
    // MARK: UIViewController
    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: 42.4474, longitude: -76.4855, zoom: 15.5) // Random cornell location
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.delegate = self
        self.mapView = mapView
        view = mapView

        initPolyline()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.isMyLocationEnabled = true
        stops = getStops()
        let locations = stops
            .map { $0.getLocation() }
            .map { CLLocationCoordinate2DMake(CLLocationDegrees($0.lat), CLLocationDegrees($0.long))}
        setLocations(locations: locations)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: Custom Functions
    
    func setLocations(locations: [CLLocationCoordinate2D]) {
        let (north, south, east, west) =
            locations.reduce((0, 50, -80, 0), { prevResult, nextLocation in
                return (max(nextLocation.latitude, prevResult.0),
                        min(nextLocation.latitude, prevResult.1),
                        max(nextLocation.longitude, prevResult.2),
                        min(nextLocation.longitude, prevResult.3))
            })
        
        panBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(north, east),
                                        coordinate: CLLocationCoordinate2DMake(south, west))
        let cameraUpdate = GMSCameraUpdate.fit(panBounds, withPadding: kBoundPadding)
        mapView.moveCamera(cameraUpdate)
        mapView.setMinZoom(mapView.camera.zoom, maxZoom: mapView.maxZoom)
        drawPins(withLocations: locations)
    }
    
    func drawPins(withLocations locations: [CLLocationCoordinate2D]) {
        var counter = 0
        for location in locations {
            let marker = GMSMarker()
            marker.position = location
        
            //add each stop to each marker
            marker.userData = stops[counter]
            counter += 1
            marker.map = mapView
        }
    }
    
    
    //drawing
    func initPolyline() {
        let stops = getStops()
        let stopsA = Array(stops[1...maxWayPoints]) //can only have a max of 8 waypoints (i.e. stops that don't include start and end)
        
        polyline.getPolyline(waypoints: stopsA, origin:stops[0], end:stops[9])
        drawRoute()
        
        polyline.getPolyline(waypoints: [], origin: stops[9], end: stops[0])
        drawRoute()
    }

    func drawRoute() {
        let path1 = GMSMutablePath(fromEncodedPath: polyline.overviewPolyline)
        let routePolyline = GMSPolyline(path: path1)

        routePolyline.strokeColor = .brsred
        routePolyline.strokeWidth = 4.0
        
        routePolyline.map = mapView
    }
    
    // MARK: GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if panBounds.contains(position.target) {
            return
        }
        
        let center = mapView.camera.target
        let newLong = min(max(center.longitude, panBounds.southWest.longitude), panBounds.northEast.longitude)
        let newLat = min(max(center.latitude, panBounds.southWest.latitude), panBounds.northEast.latitude)
        let update = GMSCameraUpdate.setTarget(CLLocationCoordinate2DMake(newLat, newLong))
        mapView.animate(with: update)
    }
    
    
    /*
     This function displays/hides the popUpView.
     */
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        latitude = marker.position.latitude
        longitude = marker.position.longitude
        if(currentMarker == nil) {
            currentMarker = marker
            popUp(stop: marker.userData as! Stop)
        }
            
        else if(currentMarker.position.latitude != marker.position.latitude) {
            //animate down
            dismissPopUpView(marker: marker, fullyDismissed: false)
            
            }
            
        else {
            
           dismissPopUpView(marker: marker, fullyDismissed: true)
        }
        return true
    }
    
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        if let viewWithTag = view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    
    
    func directionsButtonPressed(sender: UIButton) {
        //prepare to redirect user to map app
        let location = selectedStop.getLocation()
        
       
        if (UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)) {

        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string:
                "comgooglemaps://?saddr=&daddr=\(location.lat),\(location.long)&directionsmode=walking")!)
        }
            
        else {
                UIApplication.shared.openURL(URL(string:
                    "comgooglemaps://?saddr=&daddr=\(location.lat),\(location.long)&directionsmode=walking")!)
            }
        }
        else {
        
        let regionDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(CLLocationDegrees(location.lat), CLLocationDegrees(location.long))
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, CLLocationDistance(regionDistance), CLLocationDistance(regionDistance))
        let options: [String: Any] = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span),
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
            ]
            
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = selectedStop.name
            mapItem.openInMaps(launchOptions: options)
        
        }
    }
    
    
    
    /*Display & Animate the pop up view when a marker is selected
     */
    func popUp(stop: Stop) {
        
        selectedStop = stop
        
        let viewHeight = mapView.bounds.height
        let viewWidth = view.bounds.width
        let midHeight = CGFloat(32.0)
        
        
        let popUpViewFrame = CGRect(x: 12, y: viewHeight, width: viewWidth - 24, height: 106)
        popUpView.frame = popUpViewFrame
        popUpView.backgroundColor = UIColor.white
        
        let popUpWidth = popUpView.bounds.width
        
        //shadow on pop up view
        popUpView.layer.shadowColor = UIColor.lightGray.cgColor
        popUpView.layer.shadowOpacity = 1.0
        popUpView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        popUpView.layer.shadowRadius = 0.3
        
        //get directions button
        let directionsButton = UIButton(frame: CGRect(x: popUpWidth - 103, y: 22.5, width: 80, height: 16.5))
        directionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
        directionsButton.setTitle("Directions", for: .normal)
        directionsButton.setTitleColor(UIColor.lightGray, for: .normal)
        //getDirectionsButton.titleLabel?.sizeToFit()
        directionsButton.addTarget(self, action: #selector(directionsButtonPressed), for: .touchUpInside)
        directionsButton.center.y = midHeight
        
        //direction image
        let directionImage = UIImageView()
        directionImage.image = UIImage(cgImage: #imageLiteral(resourceName: "arrow").cgImage!, scale: 1.0, orientation: UIImageOrientation.left)
        directionImage.frame = CGRect(x: popUpWidth - 25, y: 14.25, width: 9, height: 16)
        directionImage.center.y = midHeight
        
        //location label
        let locationLabelFrame = CGRect(x: 40, y: 11.75, width: popUpWidth * 0.50, height: 26)
        let locationLabel = UILabel(frame: locationLabelFrame)
        locationLabel.text = selectedStop.name
        locationLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
        locationLabel.numberOfLines = 2
        locationLabel.center.y = midHeight
        locationLabel.sizeToFit()
        
        //location image
        let locationImage = UIImageView(image: #imageLiteral(resourceName: "location"))
        locationImage.frame = CGRect(x: 10, y: 18.5, width: 20, height: 26)
        locationLabel.center.y = midHeight
        
        //set up collectionView
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 70, height: 30)
        
        let collectionView = UICollectionView(frame: CGRect(x: 8, y: 64, width: popUpViewFrame.width - 8, height: 40), collectionViewLayout: layout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CustomTimeCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        
        let middleBorder = CALayer()
        middleBorder.frame = CGRect(x: 0, y: 64, width: popUpViewFrame.width, height: 1)
        middleBorder.backgroundColor = UIColor(red: 227/255, green: 229/255, blue: 233/255, alpha: 1.0).cgColor
       

        
        //tag views to be able to dismiss later
        popUpView.tag = 100
        collectionView.tag = 101
        locationLabel.tag = 102
        locationImage.tag = 103
        directionsButton.tag = 104
        directionImage.tag = 105
        
        popUpView.addSubview(collectionView)
        popUpView.addSubview(directionsButton)
        popUpView.addSubview(directionImage)
        popUpView.addSubview(locationLabel)
        popUpView.addSubview(locationImage)
        popUpView.layer.addSublayer(middleBorder)
        view.addSubview(popUpView)
        
       
        //animate view up
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
             collectionView.scrollToItem(at: IndexPath.init(row: 5, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
            
        self.popUpView.frame = CGRect(x: 12, y: viewHeight - 120 , width: viewWidth - 24, height: 106)
        }, completion: {
            (value: Bool) in
        })
        
        
    }
    
    
    /* Dismiss the current pop up view
     */
    func dismissPopUpView(marker: GMSMarker, fullyDismissed: Bool) {
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            self.popUpView.frame = CGRect(x: 12, y: self.view.bounds.height , width: self.view.bounds.width - 24, height: 130)
            
        }, completion: {
            (value: Bool) in
            //remove from view after they animate off screen
            if let popUpTagView = self.view.viewWithTag(100), let collectionTagView = self.popUpView.viewWithTag(101), let locationLabelTag = self.view.viewWithTag(102), let locationImageTag = self.view.viewWithTag(103), let getDirectionsTag = self.view.viewWithTag(104), let directionImageTag = self.view.viewWithTag(105) {
                popUpTagView.removeFromSuperview()
                collectionTagView.removeFromSuperview()
                locationLabelTag.removeFromSuperview()
                locationImageTag.removeFromSuperview()
                getDirectionsTag.removeFromSuperview()
                directionImageTag.removeFromSuperview()
                
                if fullyDismissed {
                self.currentMarker = nil
                } else {
                self.currentMarker = marker
                self.popUp(stop: marker.userData as! Stop)
                }
            }
        })
    }
    
    
    //MARK: collectionView Datasource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CustomTimeCell
        
        cell.textLabel.text = selectedStop.times[indexPath.row].shortDescription
        cell.textLabel.center = CGPoint(x: cell.bounds.midX, y: cell.bounds.midY)
        print("Laid out cell")
        
        
        return cell
        
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
}

