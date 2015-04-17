//
//  TableViewCell.swift
//  Example
//
//  Created by Wojciech Lukaszuk on 07/04/15.
//  Copyright (c) 2015 inFullMobile. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var leadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var panView: WobbleView!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if self.respondsToSelector(Selector("setLayoutMargins:")) {
        
            layoutMargins = UIEdgeInsetsZero
        }
        
        if self.respondsToSelector(Selector("setPreservesSuperviewLayoutMargins:")) {
            
            preservesSuperviewLayoutMargins = false
        }
        
        var avatar = UIImage(named: "ic_user")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.userAvatarImageView.image = avatar
        self.userAvatarImageView.tintColor = UIColor(red: 187/255.0, green: 193/255.0, blue: 209/255.0, alpha: 1.0)
        
        panView.edges = ViewEdge.Right
        
        var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
    }
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        
        switch(recognizer.state) {
            
        case UIGestureRecognizerState.Changed:
            
            var translation = recognizer.translationInView(recognizer.view!)
            trailingSpaceConstraint.constant = fmax(0, trailingSpaceConstraint.constant - translation.x)
            leadingSpaceConstraint.constant = fmin(0, leadingSpaceConstraint.constant + translation.x)
            recognizer.setTranslation(CGPointZero, inView: recognizer.view!)
            
        case UIGestureRecognizerState.Ended, UIGestureRecognizerState.Cancelled:
            
            leadingSpaceConstraint.constant = 0
            trailingSpaceConstraint.constant = 0
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.layoutIfNeeded()
            })
            
        default:
            trailingSpaceConstraint.constant = 0
            leadingSpaceConstraint.constant = 0
        }
    }
}

extension TableViewCell: UIGestureRecognizerDelegate
{
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        var velocity = (gestureRecognizer as! UIPanGestureRecognizer).velocityInView(gestureRecognizer.view!)
        
        return fabs(velocity.x) > fabs(velocity.y)
    }
}