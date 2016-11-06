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
    var open = false
    @IBOutlet weak var downCarrotImageView: UIImageView!
    @IBOutlet weak var magnifyingGlassImageView: UIImageView!
    @IBOutlet weak var labelImageViewPadding: NSLayoutConstraint!
    @IBOutlet weak var magnifyingGlassImageViewWidthConstraint: NSLayoutConstraint!
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    var delegate: StopSearchTableViewHeaderViewDelegate?
    
    func setupView() {
        downCarrotImageView.alpha = 0
        contentView.backgroundColor = UIColor.white
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    func didTapView() {
        open = !open
        animate(open: open, duration: 0.25)
        delegate?.didTapSearchBar()
    }
    
    func animate(open: Bool, duration: TimeInterval) {
        if open {
            UIView.animate(withDuration: duration) {
                self.magnifyingGlassImageView.alpha = 0
                self.magnifyingGlassImageViewWidthConstraint.constant = 0
                self.labelImageViewPadding.constant = 0
                self.downCarrotImageView.alpha = 1
            }
        } else {
            UIView.animate(withDuration: duration) {
                self.downCarrotImageView.alpha = 0
                self.magnifyingGlassImageView.alpha = 1
                self.magnifyingGlassImageViewWidthConstraint.constant = 20
                self.labelImageViewPadding.constant = 8
            }
        }
    }
}
