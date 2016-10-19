//
//  StopsViewController.swift
//  big-red-shuttle
//
//  Created by Kevin Greer on 10/12/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit
import GoogleMaps

class StopsViewController: UIViewController {

    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: 42.4474, longitude: -76.4855, zoom: 15.5)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        self.view = mapView
        print("getting stops!: \(getStops())")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

