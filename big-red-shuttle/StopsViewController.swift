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
import SwiftyJSON

class StopsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate,
                           UICollectionViewDataSource, StopSearchTableViewHeaderViewDelegate, GMSMapViewDelegate, ShuttleBusGPSDelegate {
    
    // MARK: Properties
    
    let kMaxBoundPadding: Double = 0.01
    let kBoundPadding: CGFloat = 40
    let kSearchTablePadding: CGFloat = 10
    let kSearchTableClosedHeight: CGFloat = 45
    let kStopZoom: Float = 16
    let polyline = Polyline()
    let maxWayPoints = 8

    var viewIsSetup = false
    var searchTableView: UITableView!
    var searchTableClosedFrame: CGRect!
    var searchTableOpenFrame: CGRect!
    var searchTableExpanded = false
    var aboutButton: UIButton!
    var popUpView = UIView()

    var selectedMarker: GMSMarker!
    var stops: [Stop]!
    var selectedStop: Stop!
    var mapView: GMSMapView!
    var panBounds: GMSCoordinateBounds!
    var shuttleBusMarker: GMSMarker?
    
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
        if viewIsSetup {
            return
        }
        mapView.isMyLocationEnabled = true
        stops = getStops()
        setupAboutButton()
        setupSearchTable()
        let locations = stops.map { $0.getCoordinate() }
        setLocations(locations: locations)
        viewIsSetup = true
        
        //observe gps data changes
        GPS.shared.addObserver(observer: self)
        Location.shared.fetchedUserLocationCompletionBlock = {
            if !GPS.shared.registeredToLogLocation {
                API.shared.registerUserToLogLocation(key: "fedorko", success: { (json: JSON?) in
                    GPS.shared.startLoggingShuttleLocation()
                    GPS.shared.startFetchingShuttleLocation()
                }, failure: nil)
            }
        }
    }
    
    //MARK: - Shuttle Bus GPS Delegate Protocol Methods
    func gps(gps: GPS, movedToCoordinate coordinate: Coordinate) {
        
        if let localShuttleBusMarker = shuttleBusMarker {
            
            DispatchQueue.main.async {
                CATransaction.begin()
                CATransaction.setAnimationDuration(1.0)
                let angle = atan2(localShuttleBusMarker.position.latitude - coordinate.latitude, localShuttleBusMarker.position.longitude - coordinate.longitude)
                localShuttleBusMarker.position = coordinate.asCLLocationCoordinate2D()
                localShuttleBusMarker.rotation = angle * 180.0 / M_PI
                
                CATransaction.commit()
            }

        } else {
            shuttleBusMarker = GMSMarker(position: coordinate.asCLLocationCoordinate2D())
            shuttleBusMarker?.icon = #imageLiteral(resourceName: "shuttle_icon")
            shuttleBusMarker?.map = mapView
        }
    }
    
    
    
    func setupAboutButton() {
        aboutButton = UIButton(frame: CGRect(x: 0, y: 0, width: 82, height: 40))
        aboutButton.center = CGPoint(x: view.frame.maxX-aboutButton.frame.width/2-16,
                                     y: view.frame.maxY-aboutButton.frame.height/2-16)
        aboutButton.backgroundColor = .white
        aboutButton.layer.cornerRadius = 4
        aboutButton.layer.borderColor = UIColor(white: 0.75, alpha: 1).cgColor
        aboutButton.layer.borderWidth = 0.5
        aboutButton.setTitleColor(.brsgreyedout, for: .normal)
        aboutButton.setTitle(" About", for: .normal)
        aboutButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        aboutButton.setImage(#imageLiteral(resourceName: "about-icon"), for: .normal)
        aboutButton.addTarget(self, action: #selector(didTapAboutButton), for: .touchUpInside)
        view.addSubview(aboutButton)
    }
    
    func didTapAboutButton() {
        let aboutVC = AboutViewController()
        aboutVC.modalTransitionStyle = .crossDissolve
        aboutVC.modalPresentationStyle = .overCurrentContext
        present(aboutVC, animated: true, completion: nil)
    }
    
    func setupSearchTable() {
        searchTableClosedFrame = CGRect(x: kSearchTablePadding, y: 20+kSearchTablePadding,
                                        width: view.frame.width-kSearchTablePadding*2, height: kSearchTableClosedHeight)
        searchTableOpenFrame = CGRect(x: kSearchTablePadding, y: 20+kSearchTablePadding,
                                      width: view.frame.width-kSearchTablePadding*2,
                                      height: view.frame.height-kSearchTablePadding-tabBarController!.tabBar.frame.size.height)
        
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
        searchTableView.bounces = true
        
        view.addSubview(searchTableView)
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
        let startBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(north, east),
                                        coordinate: CLLocationCoordinate2DMake(south, west))
        panBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(north+kMaxBoundPadding, east+kMaxBoundPadding),
                                         coordinate: CLLocationCoordinate2DMake(south-kMaxBoundPadding, west-kMaxBoundPadding))
        let cameraUpdate = GMSCameraUpdate.fit(startBounds, withPadding: kBoundPadding)
        mapView.moveCamera(cameraUpdate)
        mapView.setMinZoom(mapView.camera.zoom, maxZoom: mapView.maxZoom)
        drawPins()
    }
    
    func drawPins() {
        var counter = 0
        let stops = getUniqueStops()
        for stop in stops {
            let location = CLLocationCoordinate2DMake(CLLocationDegrees(stop.lat), CLLocationDegrees(stop.long))
            let marker = GMSMarker(position: location)
            
            //add each stop to each marker
            marker.userData = stops[counter]
            
            marker.iconView = stop.nextArrivalsToday().count > 0 ? IconViewBig() :  IconViewSmall()
            let iconView = marker.iconView as! IconView
            let fullString = stop.nextArrival()
            let needles:[Character] = ["a", "p"]
            
            for needle in needles {
                if let index = fullString.characters.index(of: needle) {
                    iconView.timeLabel.text = fullString.substring(to: index)
                }
            }
            
            marker.map = mapView
            counter += 1
        }
    }

    
    //drawing
    func initPolyline() {
        let stops = getStops()
        let stopsA = Array(stops[1...maxWayPoints]) //can only have a max of 8 waypoints (i.e. stops that don't include start and end)
        
        polyline.getPolyline(waypoints: stopsA, origin:stops[0], end:stops[maxWayPoints+1])
        drawRoute()
        
        polyline.getPolyline(waypoints: [], origin: stops[9], end: stops[0])
        drawRoute()
    }

    func drawRoute() {
        let path = GMSMutablePath(fromEncodedPath: polyline.overviewPolyline)
        let routePolyline = GMSPolyline(path: path)

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
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if let marker = selectedMarker {
            let iconView = marker.iconView as! IconView
            animateMarker(iconView: iconView, scale: 1.0, select: false)
        }
        if let stop = selectedStop {
            dismissPopUpView(newPopupStop: stop, fullyDismissed: true)
        }
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
        popUp(stop: stop)
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
        if searchTableExpanded {
            dismissPopUpView(newPopupStop: nil, fullyDismissed: true)
        }
        let finalFrame = (searchTableExpanded ? searchTableOpenFrame : searchTableClosedFrame)!
        
        UIView.animate(withDuration: 0.25) {
            self.searchTableView.frame = finalFrame
        }
    }
    
    /*This function displays/hides the popUpView based on tapping the marker.*/
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if selectedStop == nil {
            popUp(stop: marker.userData as! Stop)
        } else {
            let newStop = marker.userData as! Stop
            dismissPopUpView(newPopupStop: newStop, fullyDismissed: selectedStop == newStop)
        }

        if let markerCurr = selectedMarker {
            let iconView = markerCurr.iconView as! IconView
            animateMarker(iconView: iconView, scale: 1.0, select: false)
        }

        let iconView = marker.iconView as! IconView
        if !iconView.clicked! {
            animateMarker(iconView: iconView, scale: 1.1, select: true)
            selectedMarker = marker
        } else {
            animateMarker(iconView: iconView, scale: 1.0, select: false)
            selectedMarker = nil
        }
        return true
    }
    
    func animateMarker(iconView: IconView, scale: CGFloat, select: Bool) {
        UIButton.animate(withDuration: 0.15, animations: {
            iconView.circleView.transform = CGAffineTransform(scaleX: scale, y: scale)
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            iconView.smallGrayCircle.strokeColor = select ? UIColor.brsred.cgColor : UIColor.iconlightgray.cgColor

            CATransaction.commit()
        })
        { (finished:Bool) in
            if finished {
                iconView.clicked = select
            }
        }
    }
    
    func directionsButtonPressed(sender: UIButton) {
        //prepare to redirect user to map app
        
        let location = selectedStop.getLocation()
        let googleURL = "comgooglemaps://?saddr=&daddr=\(location.lat),\(location.long)&directionsmode=walking"
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string:
                    googleURL)!)
            } else {
                UIApplication.shared.openURL(URL(string:
                    googleURL)!)
            }
        } else {
            
            let regionDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(CLLocationDegrees(location.lat), CLLocationDegrees(location.long))
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, CLLocationDistance(regionDistance), CLLocationDistance(regionDistance))
            let options: [String: Any] = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span),
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = selectedStop.name
            mapItem.openInMaps(launchOptions: options)
        }
    }
    
    
    func getDayOfWeek(today: Date) -> Int {
        return Calendar(identifier: .gregorian).component(.weekday, from: today)
    }
    
    
    /* Display & Animate the pop up view when a marker is selected */
    func popUp(stop: Stop) {
        selectedStop = stop
        
        let viewHeight = mapView.bounds.height
        let viewWidth = view.bounds.width
        let midHeight = CGFloat(32.0)
        let popUpWidth = viewWidth - 24
        
        let popUpViewFrame = CGRect(x: 12, y: viewHeight, width: popUpWidth, height: 106)
        popUpView.frame = popUpViewFrame
        popUpView.backgroundColor = .white
        
        popUpView.layer.shadowColor = UIColor.lightGray.cgColor
        popUpView.layer.shadowOpacity = 1.0
        popUpView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        popUpView.layer.shadowRadius = 0.3
        
        let directionsButton = UIButton(frame: CGRect(x: popUpWidth - 103, y: 22.5, width: 80, height: 16.5))
        directionsButton.titleLabel?.font = .systemFont(ofSize: 14, weight: UIFontWeightSemibold)
        directionsButton.setTitle("Directions", for: .normal)
        directionsButton.setTitleColor(.lightGray, for: .normal)
        directionsButton.addTarget(self, action: #selector(directionsButtonPressed), for: .touchUpInside)
        directionsButton.center.y = midHeight
        
        let directionImage = UIImageView()
        directionImage.image = UIImage(cgImage: #imageLiteral(resourceName: "arrow").cgImage!, scale: 1.0, orientation: .left)
        directionImage.frame = CGRect(x: popUpWidth - 25, y: 14.25, width: 9, height: 16)
        directionImage.center.y = midHeight
        
        let locationLabelFrame = CGRect(x: 40, y: 11.75, width: popUpWidth * 0.50, height: 26)
        let locationLabel = UILabel(frame: locationLabelFrame)
        locationLabel.text = selectedStop.name
        locationLabel.font = .systemFont(ofSize: 16, weight: UIFontWeightSemibold)
        locationLabel.numberOfLines = 2
        locationLabel.center.y = midHeight
        locationLabel.sizeToFit()
        
        let locationImage = UIImageView(image: #imageLiteral(resourceName: "location"))
        locationImage.frame = CGRect(x: 10, y: 18.5, width: 20, height: 26)
        locationLabel.center.y = midHeight
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 70, height: 30)
        let collectionView = UICollectionView(frame: CGRect(x: 8, y: 64, width: popUpViewFrame.width - 8, height: 40), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CustomTimeCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        
        let middleBorder = CALayer()
        middleBorder.frame = CGRect(x: 0, y: 64, width: popUpViewFrame.width, height: 1)
        middleBorder.backgroundColor = UIColor.brsgray.cgColor
        
        popUpView.addSubview(collectionView)
        popUpView.addSubview(directionsButton)
        popUpView.addSubview(directionImage)
        popUpView.addSubview(locationLabel)
        popUpView.addSubview(locationImage)
        popUpView.layer.addSublayer(middleBorder)
        view.addSubview(popUpView)
        
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.popUpView.frame = CGRect(x: 12, y: viewHeight - 120 , width: popUpWidth, height: 106)
        }, completion: { _ in
            let nudgeCount = UserDefaults.standard.value(forKey: "nudgeCount") as! Int
            if nudgeCount < 3 && UserDefaults.standard.value(forKey: "didFireNudge") as! Bool {
                
                UIView.animate(withDuration: 0.2, delay: 0.3, options: .curveEaseInOut, animations: {
                    collectionView.contentOffset.x = collectionView.contentOffset.x + 20
                }, completion: { _ in
                    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                        collectionView.contentOffset.x = collectionView.contentOffset.x - 20
                    }, completion: nil)
                })
                UserDefaults.standard.setValue(nudgeCount + 1, forKey: "nudgeCount")
                UserDefaults.standard.setValue(false, forKey: "didFireNudge")
            }
        })
    }
    
    
    /* Dismiss the current pop up view */
    func dismissPopUpView(newPopupStop: Stop?, fullyDismissed: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            self.popUpView.frame = CGRect(x: 12, y: self.view.bounds.height , width: self.view.bounds.width - 24, height: 130)
        }, completion: { _ in
            //remove from view after they animate off screen
            self.popUpView.subviews.forEach({$0.removeFromSuperview()})
            self.popUpView.removeFromSuperview()
            if fullyDismissed {
                self.selectedStop = nil
            } else {
                if let stop = newPopupStop {
                   self.popUp(stop: stop)
                }
            }
        })
    }
    
    
    //MARK: collectionView Datasource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CustomTimeCell
        let currentDay = Days.fromNumber(num: getDayOfWeek(today: Date()))
        if selectedStop.days.contains(currentDay!){
            let nextArrivalsToday = selectedStop.nextArrivalsToday()
            cell.textLabel.text = nextArrivalsToday[indexPath.row]
            cell.textLabel.center = CGPoint(x: cell.bounds.midX, y: cell.bounds.midY)
        } else {
            cell.textLabel.text = "No Shuttles Running Today"
            cell.textLabel.sizeToFit()
            cell.textLabel.center.y = cell.bounds.midY
            
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        let currentDay = Days.fromNumber(num: getDayOfWeek(today: Date()))
        return selectedStop.days.contains(currentDay!) ? selectedStop.nextArrivalsToday().count : 1
    }
}

