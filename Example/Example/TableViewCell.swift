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
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 8.0, *) {
            layoutMargins = UIEdgeInsetsZero
            preservesSuperviewLayoutMargins = false
        }

        let avatar = UIImage(named: "ic_user")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        avatarImageView.image = avatar
        avatarImageView.tintColor = UIColor(red: 187/255.0, green: 193/255.0, blue: 209/255.0, alpha: 1.0)
        
        panView.edges = ViewEdge.Right
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        panView.reset()
    }
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        
        switch(recognizer.state) {
            
        case UIGestureRecognizerState.Changed:
            
            let translation = recognizer.translationInView(recognizer.view!)
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
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer.isKindOfClass(UIPanGestureRecognizer) {
            
            let velocity = (gestureRecognizer as! UIPanGestureRecognizer).velocityInView(gestureRecognizer.view!)
            
            return fabs(velocity.x) > fabs(velocity.y)
        }
        
        return true;
    }

}
