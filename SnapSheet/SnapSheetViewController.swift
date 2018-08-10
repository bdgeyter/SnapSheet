//
//  SnapSheetViewController.swift.swift
//  SnapSheet
//
//  Created by Bram De Geyter on 03/08/2018.
//  Copyright © 2018 Palaplu. All rights reserved.
//

import UIKit

class SnapSheetViewController: UIViewController {
    
    //MARK: - INTERFACE
    var viewController: UIViewController? {
        didSet {
            guard viewController != oldValue else { return }
            if let oldViewController = oldValue {
                removeOld(oldViewController)
            }
            if let newViewController = viewController {
                embedNew(newViewController)
            }
        }
    }
    
    // MARK: - VIEWS
    private let sheet: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        view.layer.cornerRadius = 8.0
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 2.0
        return view
    }()
    
    // MARK: - PHYSICS
    private lazy var animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: view)
    private lazy var slideAlongYAxis: UIDynamicItemBehavior = {
        let slideAlongYAxis = UIDynamicItemBehavior(items: [sheet])
        slideAlongYAxis.allowsRotation = false
        return slideAlongYAxis
    }()
    private lazy var snap = UISnapBehavior(item: sheet, snapTo: view.center)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Pan
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        sheet.addGestureRecognizer(pan)
        
        //Sheet
        sheet.frame = CGRect(x: 0.0, y: view.bounds.height - 100.0, width: view.bounds.width, height: view.bounds.height)
        view.addSubview(sheet)
        
        //Physics
        animator.addBehavior(slideAlongYAxis)
        slideAlongYAxis.addChildBehavior(snap)
    }

    @objc func didPan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            //translation
            let deltaY = gesture.translation(in: sheet.superview).y
            snap.snapPoint.y += deltaY
            gesture.setTranslation(.zero, in: sheet.superview)
        case .ended:
            let velocity = gesture.velocity(in: sheet.superview)
            slideAlongYAxis.addLinearVelocity( CGPoint(x: 0.0, y: velocity.y), for: sheet)
            if velocity.y > 0 {
                //down
                let locationY = gesture.location(in: sheet.superview).y
                let maxY = view.bounds.height - 100
                guard locationY < maxY else {
                    dismiss(animated: true, completion: nil)
                    return
                }
                snap.snapPoint.y = maxY
            } else {
                //up
                snap.snapPoint.y = 100
            }
        default:
            break
        }
    }
    
    private func removeOld(_ childViewController: UIViewController) {
        willMove(toParentViewController: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParentViewController()
    }
    
    private func embedNew(_ childViewController: UIViewController) {
        childViewController.willMove(toParentViewController: self)
        addChildViewController(childViewController)
        childViewController.view.frame = sheet.bounds
        sheet.addSubview(childViewController.view)
        childViewController.didMove(toParentViewController: self)
    }
}

