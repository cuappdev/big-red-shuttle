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
    @IBOutlet weak var findStopsLabel: UILabel!
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    var delegate: StopSearchTableViewHeaderViewDelegate?
    
    let kCarrotPadding: CGFloat = 16
    let kCarrotHeight: CGFloat = 10
    let kCarrotWidth: CGFloat = 20

    func setupView() {
        contentView.backgroundColor = .white
        findStopsLabel.textColor = .brsblack
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(tapGestureRecognizer)
        downCarrotImageView.image = #imageLiteral(resourceName: "arrow")
    }
    
    func didTapView() {
        open = !open
        animate(open: open, duration: 0.25)
        delegate?.didTapSearchBar()
    }
    
    func animate(open: Bool, duration: TimeInterval) {
        var color: UIColor!
        if open {
            color = .brsgreyedout
        } else {
            color = .brsblack
        }
        let transform = CATransform3DRotate(downCarrotImageView.layer.transform, CGFloat(M_PI), 1.0, 0, 0)
        UIView.transition(with: findStopsLabel, duration: duration, options: .transitionCrossDissolve, animations: {
            self.findStopsLabel.textColor = color
            self.downCarrotImageView.layer.transform = transform
            }, completion: nil)
    }
}
