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
        
        let popUpViewFrame = CGRect(x: 12, y: viewHeight, width: viewWidth - 24, height: 130)
        popUpView.frame = popUpViewFrame
        popUpView.backgroundColor = UIColor.white
        
        //shadow on pop up view
        popUpView.layer.shadowColor = UIColor.lightGray.cgColor
        popUpView.layer.shadowOpacity = 1.0
        popUpView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        popUpView.layer.shadowRadius = 0.3
        
        //get directions button
        let getDirectionsButton = UIButton(frame: CGRect(x: 30, y: 100, width: 120, height: 20))
        getDirectionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
        getDirectionsButton.setTitle("Get Directions", for: .normal)
        getDirectionsButton.setTitleColor(UIColor.lightGray, for: .normal)
        getDirectionsButton.titleLabel?.sizeToFit()
        getDirectionsButton.addTarget(self, action: #selector(directionsButtonPressed), for: .touchUpInside)
        
        //location label
        let locationLabelFrame = CGRect(x: 40, y: 10, width: 120, height: 20)
        let locationLabel = UILabel(frame: locationLabelFrame)
        locationLabel.text = selectedStop.name
        locationLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightSemibold)
        locationLabel.sizeToFit()
        
        //set up collectionView
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 70, height: 30)
        
        let collectionView = UICollectionView(frame: CGRect(x: 4, y: 35, width: popUpViewFrame.width - 8, height: 60), collectionViewLayout: layout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "timeCell")
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        
        //tag views to be able to dismiss later
        popUpView.tag = 100
        collectionView.tag = 101
        locationLabel.tag = 102
        
        popUpView.addSubview(collectionView)
        popUpView.addSubview(getDirectionsButton)
        popUpView.addSubview(locationLabel)
        view.addSubview(popUpView)
        
        //animate view up
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            
        self.popUpView.frame = CGRect(x: 12, y: viewHeight - 150 , width: viewWidth - 24, height: 130)
        }, completion: nil)
    }
    
    
    /* Dismiss the current pop up view
     */
    func dismissPopUpView(marker: GMSMarker, fullyDismissed: Bool) {
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            self.popUpView.frame = CGRect(x: 12, y: self.view.bounds.height , width: self.view.bounds.width - 24, height: 130)
            
        }, completion: {
            (value: Bool) in
            //remove from view after they animate off screen
            if let popUpTagView = self.view.viewWithTag(100), let collectionTagView = self.popUpView.viewWithTag(101), let locationLabelTag = self.view.viewWithTag(102) {
                popUpTagView.removeFromSuperview()
                collectionTagView.removeFromSuperview()
                locationLabelTag.removeFromSuperview()
                
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeCell", for: indexPath)
        
        let timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 58, height: 20.5))
        
        
        timeLabel.text = selectedStop.times[indexPath.row].shortDescription
        
        timeLabel.font = UIFont.systemFont(ofSize: 13.5, weight: UIFontWeightRegular)
        timeLabel.textAlignment = .center
        timeLabel.textColor = UIColor.lightGray
        timeLabel.center = CGPoint(x: cell.bounds.midX, y: cell.bounds.midY)
        
        cell.backgroundColor = UIColor(red: 243/255, green: 244/255, blue: 244/255, alpha: 1.0)
        cell.layer.cornerRadius = 2.0
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.masksToBounds = true
        cell.addSubview(timeLabel)
        
        return cell
        
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
}

