//
//  StopsViewController.swift
//  big-red-shuttle
//
//  Created by Kevin Greer on 10/12/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit
import GoogleMaps

class StopsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
                           StopSearchTableViewHeaderViewDelegate, GMSMapViewDelegate {
    
    // MARK: Properties
    
    let kMaxBoundPadding: Double = 0.01
    let kBoundPadding: CGFloat = 40
    let kSearchTablePadding: CGFloat = 10
    let kSearchTableClosedHeight: CGFloat = 45
    let kStopZoom: Float = 16

    var viewIsSetup = false
    var searchTableView: UITableView!
    var searchTableClosedFrame: CGRect!
    var searchTableOpenFrame: CGRect!
    var searchTableExpanded = false
    
    var stops: [Stop]!
    var mapView: GMSMapView!
    var panBounds: GMSCoordinateBounds!

    // MARK: UIViewController

    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: 42.4474, longitude: -76.4855, zoom: 15.5) // Random cornell location
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.delegate = self
        self.mapView = mapView
        view = mapView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewIsSetup {
            return
        }
        stops = getStops()
        setupSearchTable()
        let locations = stops.map { $0.getCoordinate() }
        setLocations(locations: locations)
        viewIsSetup = true
    }
    
    // MARK: Custom Functions
    
    func setupSearchTable() {
        searchTableClosedFrame = CGRect(x: kSearchTablePadding, y: 20+kSearchTablePadding,
                                        width: view.frame.width-kSearchTablePadding*2, height: kSearchTableClosedHeight)
        searchTableOpenFrame = CGRect(x: kSearchTablePadding, y: 20+kSearchTablePadding,
                                      width: view.frame.width-kSearchTablePadding*2,
                                      height: view.frame.height-kSearchTablePadding-98) //todo: find correct tab bar height
        
        searchTableView = UITableView(frame: searchTableClosedFrame)
        searchTableView.register(UINib(nibName: "StopSearchTableViewHeaderView", bundle: nil),
                                 forHeaderFooterViewReuseIdentifier: "HeaderView")
        searchTableView.register(UINib(nibName: "StopSearchTableViewCell", bundle: nil),
                                 forCellReuseIdentifier: "Cell")
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        searchTableView.layer.cornerRadius = 4
        searchTableView.layer.borderColor = UIColor(white: 0.75, alpha: 1).cgColor
        searchTableView.layer.borderWidth = 0.5
        searchTableView.showsVerticalScrollIndicator = false
        searchTableView.bounces = false
        
        view.addSubview(searchTableView)
    }
    
    func setLocations(locations: [CLLocationCoordinate2D]) {
        let (north, south, east, west) =
            locations.reduce((0, 50, -80, 0), { prevResult, nextLocation in
                return (max(nextLocation.latitude, prevResult.0),
                        min(nextLocation.latitude, prevResult.1),
                        max(nextLocation.longitude, prevResult.2),
                        min(nextLocation.longitude, prevResult.3))
        })
        let startBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(north, east),
                                        coordinate: CLLocationCoordinate2DMake(south, west))
        panBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(north+kMaxBoundPadding, east+kMaxBoundPadding),
                                         coordinate: CLLocationCoordinate2DMake(south-kMaxBoundPadding, west-kMaxBoundPadding))
        let cameraUpdate = GMSCameraUpdate.fit(startBounds, withPadding: kBoundPadding)
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
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view =  tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as! StopSearchTableViewHeaderView
        view.setupView()
        view.delegate = self
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kSearchTableClosedHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stop = stops[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        didTapSearchBar()
        let cameraUpdate = GMSCameraUpdate.setTarget(stop.getCoordinate(), zoom: kStopZoom)
        mapView.animate(with: cameraUpdate)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! StopSearchTableViewCell
        cell.setupCell(stop: stops[indexPath.row])
        return cell
    }
    
    // MARK: StopSearchTableViewHeaderViewDelegate
    
    func didTapSearchBar() {
        searchTableExpanded = !searchTableExpanded
        let finalFrame = (searchTableExpanded ? searchTableOpenFrame : searchTableClosedFrame)!
        
        UIView.animate(withDuration: 0.25) {
            self.searchTableView.frame = finalFrame
        }
    }
}

