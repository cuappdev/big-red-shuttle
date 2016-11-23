//
//  AboutSection.swift
//  big-red-shuttle
//
//  Created by Annie Cheng on 11/21/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import Foundation

public class AboutSection: NSObject {
    
    public var title: String
    public var summary: String
    public var link: String
    
    public init(title: String, summary: String, link: String) {
        self.title = title
        self.summary = summary
        self.link = link
    }
    
}
