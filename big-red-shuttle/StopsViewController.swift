//
//  StopsViewController.swift
//  big-red-shuttle
//
//  Created by Kevin Greer on 10/12/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit
import GoogleMaps

class StopsViewController: UIViewController, GMSMapViewDelegate {
    
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

        routePolyline.strokeColor = UIColor(red: 206/255, green: 73/255, blue: 55/255, alpha: 1.0)
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
}

