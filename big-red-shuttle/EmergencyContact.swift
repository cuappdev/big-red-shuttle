//
//  EmergencyContact.swift
//  big-red-shuttle
//
//  Created by Annie Cheng on 11/21/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import Foundation

public class EmergencyContact: NSObject {
    
    public var service: String
    public var number: String
    
    public init(service: String, number: String) {
        self.service = service
        self.number = number
    }
    
}
