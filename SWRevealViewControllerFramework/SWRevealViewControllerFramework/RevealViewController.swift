//
//  RevealViewController.swift
//  MapSample
//
//  Created by Patrick BODET on 14/04/2016.
//  Copyright © 2016 iDevelopper. All rights reserved.
//

import UIKit

class RevealViewController: SWRevealViewController, SWRevealViewControllerDelegate, UIGestureRecognizerDelegate {
    
    var width = UIScreen.mainScreen().bounds.size.width
    let ratio: CGFloat = 0.33
    var menuWidth: CGFloat?
    var menuIsOpen: Bool = false
    var rightMenuIsOpen: Bool = false
    
    var rightWidth: CGFloat? // Size of right view when menu is open
    
    var tapRecognizer: UITapGestureRecognizer?
    
    var coverView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Size of right view when menu is open
        rightWidth = UIScreen.mainScreen().bounds.size.width * ratio
        menuWidth = width - rightWidth!
        
        self.delegate = self
        
        toggleAnimationType = .EaseOut
        
        rightViewRevealWidth = width
        rightViewRevealOverdraw = 0
        rightViewRevealDisplacement = 0
        
        rightViewController.view.addGestureRecognizer(panGestureRecognizer())
        
        // Remove SW target and action
        panGestureRecognizer().removeTarget(nil, action: nil)
        
        // Add ours ones
        panGestureRecognizer().addTarget(self, action: #selector(handlePan(_:)))
        panGestureRecognizer().delegate = self
        
        frontViewPosition = .LeftSideMost
        
        coverView = UIView(frame: UIScreen.mainScreen().bounds)
        coverView?.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapRecognizer?.numberOfTouchesRequired = 1
        tapRecognizer?.cancelsTouchesInView = false
        
        coverView?.addGestureRecognizer(tapRecognizer!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        width = size.width
        self.rightViewRevealWidth = rightWidth!
        self.rightViewRevealOverdraw = width - rightWidth!
        
        if rightMenuIsOpen {
            // Workarround. I close the right menu if it is open because the position is bad after the rotation to landscape
            // dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func openMenu() {
        //print("Open")
        menuIsOpen = true
        self.rightViewRevealWidth = rightWidth!
        self.rightViewRevealOverdraw = width - rightWidth!
        self.rightViewController.view.addSubview(coverView!)
        self.setFrontViewPosition(.LeftSide, animated: true)
    }
    
    func closeMenu(animated: Bool) {
        //print("Close")
        menuIsOpen = false
        if animated {
            //self.rightViewRevealWidth = rightWidth! - 50
            //self.rightViewRevealOverdraw = width - self.rightViewRevealWidth
            //self.setFrontViewPosition(.LeftSide, animated: true)
            //performSelector(#selector(RevealViewController.showRight), withObject: nil, afterDelay: 0.2)
            showRight()
        }
        else {
            showRight()
        }
    }
    
    func showRight() {
        var frame = self.rightViewController.view.frame
        frame.origin.x = 0
        
        UIView.animateWithDuration(0.5) {
            self.rightViewController.view.frame = frame
            self.rightViewRevealWidth = self.width
            self.rightViewRevealOverdraw = 0
            self.coverView?.removeFromSuperview()
            self.setFrontViewPosition(.LeftSideMost, animated: true)
        }
    }
    
    func reveal(sender: AnyObject?) {
        if self.frontViewPosition == .LeftSide {
            closeMenu(true)
        }
        else {
            openMenu()
        }
    }
    
    //MARK: - UIGestureRecognizer actions
    
    func handleTap(sender: UITapGestureRecognizer) {
        //reveal(self)
        closeMenu(false)
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        let position = sender.translationInView(rightViewController.view).x
        //print("Position: \(position)")
        let velocity = sender.velocityInView(rightViewController.view).x
        //print("Velocity: \(velocity)")
        
        switch sender.state {
        case .Began:
            if velocity >= quickFlickVelocity {
                openMenu()
            }
        case .Changed:
            if menuIsOpen {break}
            rightViewRevealWidth = UIScreen.mainScreen().bounds.size.width - position
            rightViewRevealOverdraw = width - rightViewRevealWidth;
            setFrontViewPosition(.LeftSide, animated: false)
        case .Ended:
            if menuIsOpen {break}
            if position < (width - rightWidth!) / 2 {
                closeMenu(false)
            }
            else {
                openMenu()
            }
        default:
            break
        }
    }
    
    //MARK: - UIGestureRecognizer delegate
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tapRecognizer {
            return true
        }
        if gestureRecognizer == panGestureRecognizer() {
            let velocity = panGestureRecognizer().velocityInView(rightViewController.view)
            if velocity.x > 0 {
                return true
            }
        }
        return false
    }
    
    //MARK: - SWRevealViewControllerDelegate
    
    func revealController(revealController: SWRevealViewController!, willMoveToPosition position: FrontViewPosition) {
        print("willmove")
        if position == .LeftSide && rightMenuIsOpen {
            
            // Close the right menu (popover)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func revealController(revealController: SWRevealViewController!, didMoveToPosition position: FrontViewPosition) {
    }
}
