//
//  StopsViewController.swift
//  big-red-shuttle
//
//  Created by Kevin Greer on 10/12/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit
import GoogleMaps

class StopsViewController: UIViewController, GMSMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Properties

    var mapView: GMSMapView!
    var panBounds: GMSCoordinateBounds!
    let kBoundPadding: CGFloat = 40
    let polyline = Polyline()
    let maxWayPoints = 8
    
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
        let locations = getStops()
                            .map { $0.getLocation() }
                            .map { CLLocationCoordinate2DMake(CLLocationDegrees($0.lat), CLLocationDegrees($0.long))}
        setLocations(locations: locations)
        //popUp()
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
        for location in locations {
            let marker = GMSMarker()
            marker.position = location
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
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        popUp()
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        if let viewWithTag = view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    //MARK: Pop Up View
    
    func popUp() {
        
        let viewHeight = mapView.bounds.height
        let viewWidth = view.bounds.width
        
        let popUpViewFrame = CGRect(x: 12, y: viewHeight - 150 , width: viewWidth - 24, height: 130)
        
        let popUpView = UIView(frame: popUpViewFrame)
        
        print("adding view")
        popUpView.backgroundColor = UIColor.white
        
        
        //collectionView
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 70, height: 30)
        let collectionView = UICollectionView(frame: CGRect(x: 14, y: popUpViewFrame.midY - 30, width: popUpViewFrame.width - 4, height: 60), collectionViewLayout: layout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "timeCell")
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        
        popUpView.tag = 100
        collectionView.tag = 100
        UIView.transition(with: self.view, duration: 2, options: .curveEaseInOut, animations: {self.view.addSubview(popUpView);self.view.addSubview(collectionView)}, completion: nil)
        //view.addSubview(popUpView)
        //view.addSubview(collectionView)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeCell", for: indexPath)
        
        let label = UILabel(frame: CGRect(x: cell.frame.minX + 4, y: cell.frame.midY - 10, width: cell.frame.maxX - 8, height: 8))
        print("Populating cell")
        label.text = "12:08 AM"
        label.textAlignment = .center
        label.textColor = UIColor.lightGray
        label.sizeToFit()
        label.center = CGPoint(x: cell.frame.midX, y: cell.frame.minY)
        
        cell.backgroundColor = UIColor(red: 243/255, green: 244/255, blue: 244/255, alpha: 1.0)
        
        cell.layer.cornerRadius = 2.0
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.masksToBounds = true
        cell.addSubview(label)
        return cell
        
    
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
}

