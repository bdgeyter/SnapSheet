//
//  ViewController.swift
//  SnapSheet
//
//  Created by Bram De Geyter on 03/08/2018.
//  Copyright © 2018 Palaplu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private let sheet: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        return view
    }()
    
    private lazy var animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: view)
    private lazy var slideAlongYAxis: UIAttachmentBehavior = {
        let slide = UIAttachmentBehavior.slidingAttachment(with: sheet, attachmentAnchor: sheet.center, axisOfTranslation: CGVector(dx: 1.0, dy: 0.0))
        return slide
    }()
    private lazy var snap = UISnapBehavior(item: sheet, snapTo: view.center)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Pan
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        sheet.addGestureRecognizer(pan)
        sheet.frame = CGRect(x: 0.0, y: view.bounds.height - 50.0, width: view.bounds.width, height: view.bounds.height)
        view.addSubview(sheet)
        
    }

    @objc func didPan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            animator.removeAllBehaviors()
            animator.addBehavior(slideAlongYAxis)
        case .changed:
            slideAlongYAxis.anchorPoint = gesture.location(in: sheet.superview)
        //case .ended:
            //animator.addBehavior(snap)
        default:
            break
        }
    }
}

