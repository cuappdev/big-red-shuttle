//
//  StopSearchTableViewHeaderView.swift
//  big-red-shuttle
//
//  Created by Kevin Greer on 11/1/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit

protocol StopSearchTableViewHeaderViewDelegate {
    func didTapSearchBar()
}

class StopSearchTableViewHeaderView: UITableViewHeaderFooterView {
    
    /**  TODO: Make this not a header view, but a separate view. 
                Create separate config for open table
    */
    var tapGestureRecognizer: UITapGestureRecognizer!
    var delegate: StopSearchTableViewHeaderViewDelegate?
    
    func setupView() {
        contentView.backgroundColor = UIColor.white
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    func didTapView() {
        delegate?.didTapSearchBar()
    }
}
