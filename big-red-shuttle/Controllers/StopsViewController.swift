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

// TODO: add ShuttleBusGPSDelegate when logging is implemented
class StopsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate,
                           UICollectionViewDataSource, GMSMapViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: Properties
    
    let kMaxBoundPadding: Double = 0.01
    let kBoundPadding: CGFloat = 60
    let kEdgePadding: CGFloat = 16
    let kSearchTableClosedHeight: CGFloat = 42
    let kStopZoom: Float = 16
    let polyline = Polyline()
    let minsThreshold: Int = 60
    
    // Popup view constants
    let topContainerHeight: CGFloat = 64
    let popupHeight: CGFloat = 106
    let popupYOffset: CGFloat = 120
    let offset: CGFloat = 12
    let cellXOffset: CGFloat = 11
    let spaceSeparator: String = String(repeating: " ", count: 5)

    var viewIsSetup = false
    var searchTableView: UITableView!
    var searchTableClosedFrame: CGRect!
    var searchTableOpenFrame: CGRect!
    var searchTableExpanded = false
    var aboutButton: UIButton!
    var popUpView = UIView()
    var popupCollectionView: UICollectionView?

    var markers: [String:GMSMarker] = [:]
    var stops: [Stop] = []
    var selectedStop: Stop!
    var mapView: GMSMapView!
    var panBounds: GMSCoordinateBounds!
    var shuttleBusMarker: GMSMarker?
    
    var searchBarHeaderView: StopSearchTableViewHeaderView!
    var dropDownMenuShadowView: UIView!
    var dropDownMenuContainerView: UIView!
    
    // MARK: UIViewController Methods
    
    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: 42.4474, longitude: -76.4855, zoom: 15.5) // Random Cornell location
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.delegate = self
        self.mapView = mapView
        view = mapView

        drawBusRoute()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewIsSetup { return }
        
        mapView.isMyLocationEnabled = true
        stops = getStops()
        setupAboutButton()
        setupSearchTable()
        let locations = stops.map { $0.getCoordinate() }
        setLocations(locations: locations)
        viewIsSetup = true
        
        // TODO: Uncomment when logging is implemented
//        GPS.shared.addObserver(observer: self)
//        Location.shared.fetchedUserLocationCompletionBlock = {
//            if !GPS.shared.registeredToLogLocation {
//                API.shared.registerUserToLogLocation(key: "fedorko", success: { (json: JSON?) in
//                    GPS.shared.startLoggingShuttleLocation()
//                    GPS.shared.startFetchingShuttleLocation()
//                }, failure: nil)
//            }
//        }
        
        // Not most elegant solution, should figure out a better way to check when time changes by a minute
        Timer.scheduledTimer(timeInterval: 5,
                             target: self,
                             selector: #selector(self.updateLocationPins),
                             userInfo: nil,
                             repeats: true)
    }
    
    // Update schedule bar every 5 seconds
    func updateScheduleBar() {
        
    }
    
    // MARK: Map and Route Drawing Methods
    
    func drawPath() {
        let path = GMSMutablePath(fromEncodedPath: polyline.overviewPolyline)
        let routePolyline = GMSPolyline(path: path)
        
        routePolyline.strokeColor = .brsred
        routePolyline.strokeWidth = 4.0
        routePolyline.map = mapView
    }
    
    func drawBusRoute() {
        let stops = getStops()
 
        if stops.count > 1 {
            let stopsA = Array(stops[1...stops.count - 1])
            
            // Draw entire route from first stop to last stop
            polyline.getPolyline(waypoints: stopsA, origin: stops.first!, end: stops.last!)
            drawPath()

            // Draw direct route from last stop back to first stop
            polyline.getPolyline(waypoints: [], origin: stops.last!, end: stops.first!)
            drawPath()
        }
    }
    
    func setLocations(locations: [CLLocationCoordinate2D]) {
        let (north, south, east, west) =
            locations.reduce((0, 50, -80, 0), { prevResult, nextLocation in
                return (max(nextLocation.latitude, prevResult.0),
                        min(nextLocation.latitude, prevResult.1),
                        max(nextLocation.longitude, prevResult.2),
                        min(nextLocation.longitude, prevResult.3))
            })
        let topMapOffset: Double = 0.003
        let startBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(north + topMapOffset, east),
                                              coordinate: CLLocationCoordinate2DMake(south, west))
        panBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2DMake(north + kMaxBoundPadding, east + kMaxBoundPadding), coordinate: CLLocationCoordinate2DMake(south - kMaxBoundPadding, west - kMaxBoundPadding))
        let cameraUpdate = GMSCameraUpdate.fit(startBounds, with: UIEdgeInsets(top: kBoundPadding + kEdgePadding+kSearchTableClosedHeight, left: kBoundPadding, bottom: kBoundPadding, right: kBoundPadding))
        mapView.moveCamera(cameraUpdate)
        mapView.setMinZoom(mapView.camera.zoom, maxZoom: mapView.maxZoom)
        
        drawLocationPins()
    }
    
    func drawLocationPins() {
        for stop in stops {
            if markers[stop.name] == nil {
                let location = CLLocationCoordinate2DMake(CLLocationDegrees(stop.lat), CLLocationDegrees(stop.long))
                let marker = GMSMarker(position: location)
                marker.userData = stop
                
                let hasArrivalsToday = stop.nextArrivalsToday().count > 0
                var previewTime = false
                
                if let currentTime = getCurrentTime() {
                    previewTime = [6, 7].contains(currentTime.day) && currentTime.hour >= 13
                }

                marker.iconView = (hasArrivalsToday || previewTime) ? IconViewBig() : IconViewSmall()
                
                updateStopTimeLabel(marker: marker, selected: false)
                
                marker.map = mapView
                markers[stop.name] = marker
            }
        }
    }
    
    // Update location pins every 5 seconds
    @objc func updateLocationPins() {
        for (_, marker) in markers {
            updateIconView(marker: marker)
        }
        
        if let collectionView = popupCollectionView {
            collectionView.reloadData()
        }
    }
    
    // Update the icon view when necessary
    func updateIconView(marker: GMSMarker) {
        let stop = marker.userData as! Stop
        var iconView = marker.iconView as! IconView
        
        let hasArrivalsToday = stop.nextArrivalsToday().count > 0
        var previewTime = false
        
        if let currentTime = getCurrentTime() {
            previewTime = [6, 7].contains(currentTime.day) && currentTime.hour >= 13
        }
        
        if hasArrivalsToday || previewTime {
            if iconView is IconViewSmall {
                changeIconView(marker: marker)
            }
        } else {
            if iconView is IconViewBig {
                changeIconView(marker: marker)
            }
        }
        
        iconView = marker.iconView as! IconView
        updateStopTimeLabel(marker: marker, selected: iconView.clicked)
    }
    
    // Change small icon view to big and vice versa when necessary
    func changeIconView(marker: GMSMarker) {
        let stop = marker.userData as! Stop
        let iconView = marker.iconView as! IconView
        let newIconView = (iconView is IconViewSmall) ? IconViewBig() : IconViewSmall()
        
        if iconView.clicked! {
            dismissPopUpView(newPopupStop: stop, fullyDismissed: true, completionHandler: { finished in
                if finished {
                    marker.iconView = newIconView
                }
            })
        } else {
            marker.iconView = newIconView
        }
    }
    
    // Update the time label on the marker
    func updateStopTimeLabel(marker: GMSMarker, selected: Bool) {
        let stop = marker.userData as! Stop
        let iconView = marker.iconView as! IconView
        
        // Show next arrival time in HH:mm format
        var preview = false
        if let currentTime = getCurrentTime() {
            preview = [6, 7].contains(currentTime.day) && currentTime.hour >= 13
        }
        
        let firstArrivalTomorrow = stop.allArrivalsTomorrow().first ?? "--"
        let nextArrivalString = preview ? firstArrivalTomorrow : stop.nextArrivalToday()
        let needles: [Character] = ["a", "p"]
        
        for needle in needles {
            if let index = nextArrivalString.index(of: needle) {
                let timeString = String(nextArrivalString[..<index])
                iconView.timeLabel.text = timeString.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        if selected {
            // If minutes until next arrival < minsThreshold, show minutes until next arrival
            let remainingMins = getMinutesUntilTime(time: nextArrivalString)
   
            if remainingMins != -1 && remainingMins <= minsThreshold {
                iconView.timeLabel.text = "\(remainingMins) min"
            }
        }
    }
    
    func didSelectStop(stop: Stop) {
        let marker: GMSMarker = markers[stop.name]!
        let newStop = marker.userData as! Stop
        
        if let _ = selectedStop {
            dismissPopUpView(newPopupStop: newStop, fullyDismissed: selectedStop == newStop, completionHandler: { _ in })
        } else {
            displayPopUpView(stop: newStop)
        }
    }
    
    func animateMarker(marker: GMSMarker, select: Bool) {
        let iconView = marker.iconView as! IconView
        
        UIButton.animate(withDuration: 0.1, animations: {
            let scale: CGFloat = iconView is IconViewBig ? 1.2 : 1.1
            let yOffset: CGFloat = iconView is IconViewBig ? -4 : -2
            
            iconView.circleView.transform = select ? CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: 0, y: yOffset) : .identity
            self.updateStopTimeLabel(marker: marker, selected: select)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            iconView.setClicked(clicked: select)
            
            CATransaction.commit()
        })
    }
    
    // MARK: About Button Methods
    
    func setupAboutButton() {
        aboutButton = UIButton(frame: CGRect(x: 0, y: 0, width: 82, height: 40))
        aboutButton.center = CGPoint(x: view.frame.maxX - aboutButton.frame.width/2 - kEdgePadding,
                                     y: view.frame.maxY - aboutButton.frame.height/2 - kEdgePadding)
        
        aboutButton.backgroundColor = .white
        aboutButton.layer.cornerRadius = 2
        aboutButton.layer.shadowColor = UIColor.bordergray.cgColor
        aboutButton.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        aboutButton.layer.shadowOpacity = 1
        aboutButton.layer.shadowRadius = 1
        aboutButton.layer.masksToBounds = false
        
        aboutButton.setTitleColor(.brsgrey, for: .normal)
        aboutButton.setTitle("About", for: .normal)
        aboutButton.titleLabel?.font = UIFont(name: "SFUIDisplay-Regular", size: 12.0)!
        aboutButton.setImage(#imageLiteral(resourceName: "AboutIcon"), for: .normal)
        aboutButton.titleEdgeInsets.right = -6
        aboutButton.imageEdgeInsets.left = -8
        
        aboutButton.addTarget(self, action: #selector(didTapAboutButton), for: .touchUpInside)
        view.addSubview(aboutButton)
    }
    
    @objc func didTapAboutButton() {
        let aboutVC = AboutViewController()
        aboutVC.modalTransitionStyle = .crossDissolve
        aboutVC.modalPresentationStyle = .overCurrentContext
        present(aboutVC, animated: true, completion: nil)
    }
    
    // MARK: Search Bar Functions
    
    func setupSearchTable() {
        searchTableClosedFrame = CGRect(x: kEdgePadding, y: kEdgePadding + 20,
                                        width: view.frame.width - 2*kEdgePadding, height: kSearchTableClosedHeight)
        searchTableOpenFrame = CGRect(x: kEdgePadding, y: kEdgePadding + 20,
                                      width: view.frame.width - 2*kEdgePadding,
                                      height: view.frame.height - tabBarController!.tabBar.frame.size.height)

        dropDownMenuShadowView = UIView(frame: searchTableClosedFrame)
        dropDownMenuShadowView.layer.cornerRadius = 1
        dropDownMenuShadowView.layer.shadowColor = UIColor.searchbordergray.cgColor
        dropDownMenuShadowView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        dropDownMenuShadowView.layer.shadowOpacity = 1
        dropDownMenuShadowView.layer.shadowRadius = 1
        
        dropDownMenuContainerView = UIView(frame: dropDownMenuShadowView.bounds)
        dropDownMenuContainerView.layer.cornerRadius = 1
        dropDownMenuContainerView.clipsToBounds = true
        dropDownMenuShadowView.addSubview(dropDownMenuContainerView)
        
        searchBarHeaderView = StopSearchTableViewHeaderView(frame: dropDownMenuContainerView.bounds)
        dropDownMenuContainerView.addSubview(searchBarHeaderView)
        
        searchTableView = UITableView(frame: CGRect(x: 0, y: searchTableClosedFrame.height, width: searchTableClosedFrame.width, height: searchTableOpenFrame.height-searchTableClosedFrame.height))
        searchTableView.register(UINib(nibName: "StopSearchTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.tableFooterView = UIView()
        searchTableView.showsVerticalScrollIndicator = false
        dropDownMenuContainerView.addSubview(searchTableView)
        
        view.addSubview(dropDownMenuShadowView)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch.view == searchBarHeaderView {
                didTapSearchBar()
            }
        }
    }
    
    // MARK: SearchTableView UITableViewDelegate Methods
    
    func tableView(_ tableViewObject: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewObject.deselectRow(at: indexPath, animated: true)
        didTapSearchBar()
        
        let stop = stops[indexPath.row]
        let cameraUpdate = GMSCameraUpdate.setTarget(stop.getCoordinate(), zoom: kStopZoom)
        mapView.animate(with: cameraUpdate)
        didSelectStop(stop: stop)
    }
    
    // MARK: SearchTableView UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stops.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! StopSearchTableViewCell
        cell.setupCell(stop: stops[indexPath.row])
        return cell
    }
    
    // MARK: StopSearchTableViewHeaderViewDelegate Methods
    
    func didTapSearchBar() {
        searchTableExpanded = !searchTableExpanded
        searchTableView.reloadData()
        
        if searchTableExpanded {
            searchTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            
            if let stop = selectedStop {
                dismissPopUpView(newPopupStop: stop, fullyDismissed: true, completionHandler: { _ in })
            }
        }
        
        let finalFrame = (searchTableExpanded ? searchTableOpenFrame : searchTableClosedFrame)!
        searchBarHeaderView.animate(open: searchTableExpanded, duration: 0.25)
        UIView.animate(withDuration: 0.25) {
            self.dropDownMenuShadowView.frame = finalFrame
            self.dropDownMenuContainerView.frame = self.dropDownMenuShadowView.bounds
        }
    }
    
    // MARK: Shuttle Stop Pop Up Methods
    
    // Create the shuttle stop popup view
    func createPopUpView() {
        let popupWidth: CGFloat = view.frame.width - 2*kEdgePadding
        
        popUpView.frame = CGRect(x: kEdgePadding, y: view.frame.height, width: popupWidth, height: popupHeight)
        popUpView.backgroundColor = .white
        popUpView.layer.cornerRadius = 2
        popUpView.layer.shadowColor = UIColor.bordergray.cgColor
        popUpView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        popUpView.layer.shadowOpacity = 1
        popUpView.layer.shadowRadius = 1
        
        let topContainerView = UIView(frame: CGRect(x: 0, y: 0, width: popupWidth, height: topContainerHeight))
        topContainerView.layer.cornerRadius = 2
        
        let locationImageView = UIImageView(image: #imageLiteral(resourceName: "RedPinIcon"))
        locationImageView.frame.size = CGSize(width: 18, height: 23.5)
        locationImageView.center = CGPoint(x: kEdgePadding + locationImageView.frame.width/2, y: topContainerView.frame.midY)
        topContainerView.addSubview(locationImageView)
        
        let stopNameLabel = UILabel(frame: CGRect(x: locationImageView.frame.maxX + offset, y: topContainerView.frame.midY,
                                                  width: popupWidth/2, height: popupHeight - 2*offset))
        stopNameLabel.text = selectedStop.name
        stopNameLabel.font = UIFont(name: "SFUIDisplay-Semibold", size: 16)!
        stopNameLabel.textColor = .brsblack
        stopNameLabel.numberOfLines = 2
        stopNameLabel.sizeToFit()
        stopNameLabel.center.y = topContainerView.frame.midY
        topContainerView.addSubview(stopNameLabel)
        
        let directionsArrowImageView = UIImageView(image: UIImage(cgImage: #imageLiteral(resourceName: "ArrowIcon").cgImage!, scale: 1.0, orientation: .left))
        directionsArrowImageView.image = directionsArrowImageView.image!.withRenderingMode(.alwaysTemplate)
        directionsArrowImageView.tintColor = .directionsgrey
        directionsArrowImageView.frame.size = CGSize(width: 9, height: 15)
        directionsArrowImageView.center = CGPoint(x: topContainerView.frame.width - kEdgePadding - directionsArrowImageView.frame.width/2, y: topContainerView.frame.midY)
        topContainerView.addSubview(directionsArrowImageView)
        
        let directionsButton = UIButton()
        directionsButton.setTitle("Directions", for: .normal)
        directionsButton.setTitleColor(.directionsgrey, for: .normal)
        directionsButton.titleLabel?.font = UIFont(name: "SFUIDisplay-Semibold", size: 14)!
        directionsButton.addTarget(self, action: #selector(directionsButtonPressed), for: .touchUpInside)
        directionsButton.sizeToFit()
        directionsButton.center = CGPoint(x: directionsArrowImageView.frame.minX - directionsButton.frame.width/2 - offset/2, y: topContainerView.frame.midY)
        topContainerView.addSubview(directionsButton)
        
        let middleBorderView = UIView(frame: CGRect(x: 0, y: topContainerView.frame.height - 1, width: topContainerView.frame.width, height: 1))
        middleBorderView.backgroundColor = .brsgray
        topContainerView.addSubview(middleBorderView)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        popupCollectionView = UICollectionView(frame: CGRect(x: 0, y: topContainerHeight, width: popupWidth, height: popupHeight - topContainerHeight), collectionViewLayout: layout)
        popupCollectionView?.delegate = self
        popupCollectionView?.dataSource = self
        popupCollectionView?.register(CustomTimeCell.self, forCellWithReuseIdentifier: "Cell")
        popupCollectionView?.backgroundColor = .clear
        popupCollectionView?.showsHorizontalScrollIndicator = false
        
        popUpView.addSubview(topContainerView)
        popUpView.addSubview(popupCollectionView!)
        view.addSubview(popUpView)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.didPanPopupView(sender:)))
        popUpView.addGestureRecognizer(panGestureRecognizer)
    }
    
    // Display and animate the pop up view when a marker is selected
    func displayPopUpView(stop: Stop) {
        selectedStop = stop
        createPopUpView()
        let nudgeOffset: CGFloat = 20
        
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            let marker: GMSMarker = self.markers[self.selectedStop.name]!
            self.animateMarker(marker: marker, select: true)
            self.popUpView.frame.origin.y = self.view.frame.height - self.popupYOffset
        }, completion: { _ in
            let nextArrivalsToday = self.selectedStop.nextArrivalsToday()
            let nudgeCount = UserDefaults.standard.value(forKey: "nudgeCount") as! Int
            if nextArrivalsToday.count > 0 && nudgeCount < 3 && UserDefaults.standard.value(forKey: "didFireNudge") as! Bool {
                UIView.animate(withDuration: 0.2, delay: 0.3, options: .curveEaseInOut, animations: {
                    self.popupCollectionView?.contentOffset.x += nudgeOffset
                }, completion: { _ in
                    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                        self.popupCollectionView?.contentOffset.x -= nudgeOffset
                    })
                })
                
                UserDefaults.standard.setValue(nudgeCount + 1, forKey: "nudgeCount")
                UserDefaults.standard.setValue(false, forKey: "didFireNudge")
            }
        })
    }
    
    // Dismiss the current pop up view
    func dismissPopUpView(newPopupStop: Stop, fullyDismissed: Bool, completionHandler: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            let marker: GMSMarker = self.markers[self.selectedStop.name]!
            self.animateMarker(marker: marker, select: false)
            self.popUpView.frame = CGRect(x: self.offset, y: self.view.bounds.height , width: self.view.bounds.width - 2*self.offset, height: self.popupHeight)
        }, completion: { finished in
            self.popUpView.subviews.forEach({$0.removeFromSuperview()})
            self.popUpView.removeFromSuperview()
            self.popupCollectionView = nil

            if fullyDismissed {
                self.selectedStop = nil
            } else {
                self.displayPopUpView(stop: newPopupStop)
            }
            
            completionHandler(finished)
        })
    }
    
    // Dismiss popup if user swipes down low enough on popup view 
    @objc func didPanPopupView(sender: UIPanGestureRecognizer) {
        let deltaY = sender.translation(in: view).y
        let newY = max(view.frame.height - popupYOffset, popUpView.frame.minY + deltaY)
        popUpView.frame = CGRect(origin: CGPoint(x: kEdgePadding, y: newY), size: popUpView.frame.size)
        sender.setTranslation(.zero, in: view)
        
        if sender.state == .ended {
            let lowEnoughToDismiss = popUpView.frame.minY > view.frame.height - 0.6*popupYOffset
            if lowEnoughToDismiss {
                if let stop = selectedStop {
                    dismissPopUpView(newPopupStop: stop, fullyDismissed: true, completionHandler: { _ in })
                }
            } else {
                let newFrame = CGRect(x: kEdgePadding, y: view.frame.height - popupYOffset, width: popUpView.frame.width, height: popUpView.frame.height)
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                    self.popUpView.frame = newFrame
                })
            }
        }
    }
    
    // Redirect user to Apple Maps or Google Maps
    @objc func directionsButtonPressed(sender: UIButton) {
        let location = selectedStop.getLocation()
        let googleURL = "comgooglemaps://?saddr=&daddr=\(location.lat),\(location.long)&directionsmode=walking"
        
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: googleURL)!)
            } else {
                UIApplication.shared.openURL(URL(string: googleURL)!)
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
    
    // MARK: Shuttle Stop Popup CollectionView Datasource Methods
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CustomTimeCell
        let cellText = getMessage(messageType: .Popup, stop: selectedStop)
        let timesStringSize = cellText.size(withAttributes: [NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Regular", size: 14)!])
        let timeStringWidth = timesStringSize.width + 2*cellXOffset
        let nextArrivalsToday = selectedStop.nextArrivalsToday()
        let labelX = (timeStringWidth > collectionView.bounds.width || nextArrivalsToday.count > 0) ? cell.bounds.midX : collectionView.bounds.midX
        
        cell.textLabel.text = cellText
        cell.textLabel.sizeToFit()
        cell.textLabel.center = CGPoint(x: labelX, y: cell.bounds.midY)
        cell.textLabel.textColor = .brsgrey
        cell.textLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 14)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellText = getMessage(messageType: .Popup, stop: selectedStop)
        let timesStringSize = cellText.size(withAttributes: [NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Regular", size: 14)!])
        let timeStringWidth = timesStringSize.width + 2*cellXOffset
        let nextArrivalsToday = selectedStop.nextArrivalsToday()
        let cellWidth = (timeStringWidth > collectionView.bounds.width || nextArrivalsToday.count > 0) ? timeStringWidth : collectionView.bounds.width
        
        return CGSize(width: cellWidth, height: collectionView.bounds.height)
    }
    
    // MARK: GMSMapViewDelegate Methods
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if panBounds.contains(position.target) { return }
        
        let center = mapView.camera.target
        let newLong = min(max(center.longitude, panBounds.southWest.longitude), panBounds.northEast.longitude)
        let newLat = min(max(center.latitude, panBounds.southWest.latitude), panBounds.northEast.latitude)
        let update = GMSCameraUpdate.setTarget(CLLocationCoordinate2DMake(newLat, newLong))
        mapView.animate(with: update)
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if let stop = selectedStop {
            dismissPopUpView(newPopupStop: stop, fullyDismissed: true, completionHandler: { _ in })
        }
    }
    
    // Display and hide the popUpView based on tapping the marker pin
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        didSelectStop(stop: marker.userData as! Stop)
        
        return true
    }
    
    // MARK: - Shuttle Shuttle GPS Delegate Protocol Methods
    
//    func gps(gps: GPS, movedToCoordinate coordinate: Coordinate) {
//        if let localShuttleBusMarker = shuttleBusMarker {
//            DispatchQueue.main.async {
//                CATransaction.begin()
//                CATransaction.setAnimationDuration(1.0)
//                let angle = atan2(localShuttleBusMarker.position.latitude - coordinate.latitude, localShuttleBusMarker.position.longitude - coordinate.longitude)
//                localShuttleBusMarker.position = coordinate.asCLLocationCoordinate2D()
//                localShuttleBusMarker.rotation = angle * 180.0 / M_PI
//                
//                CATransaction.commit()
//            }
//        } else {
//            shuttleBusMarker = GMSMarker(position: coordinate.asCLLocationCoordinate2D())
//            shuttleBusMarker?.icon = ShuttleIcon
//            shuttleBusMarker?.map = mapView
//        }
//    }

}

