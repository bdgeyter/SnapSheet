//
//  SnapSheetViewController.swift.swift
//  SnapSheet
//
//  Created by Bram De Geyter on 03/08/2018.
//  Copyright © 2018 Palaplu. All rights reserved.
//

import UIKit

public class SnapSheetViewController: UIViewController {

	public var didUpdateSheetOriginTop: ((CGFloat) -> (Void))?

	private var topAnchor: NSLayoutYAxisAnchor {
		if #available(iOS 11.0, *) {
			return view.safeAreaLayoutGuide.topAnchor
		} else {
			return view.topAnchor
		}
	}

	//MARK: - INTERFACE
	public weak var viewController: UIViewController? {
		didSet(oldViewController) {
			guard viewController != oldViewController else { return }
			removeOld(oldViewController)
			embedNew(viewController)
		}
	}

	/// The state of the sheet
	public var state: State = .closed
	public enum State {
		case open, closed, moving, dismissing
	}

	/// The sheet will snap to bottom in closed state and top in open state of this layoutGuide.
	/// Simply add constraints onto this layoutGuide to determine its position and size.
	public let sheetLayoutGuide = UILayoutGuide()

	public lazy var addSheetLayoutGuideConstraints: ((UILayoutGuide, UIView) -> Void) = { (sheetLayoutGuide, view) in
		sheetLayoutGuide.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		sheetLayoutGuide.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		sheetLayoutGuide.topAnchor.constraint(equalTo: self.topAnchor, constant: 20.0).isActive = true
		sheetLayoutGuide.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 2/3).isActive = true
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
	private lazy var snap = UISnapBehavior(item: sheet, snapTo: CGPoint(x: self.sheetLayoutGuide.layoutFrame.midX, y: self.sheetLayoutGuide.layoutFrame.maxY))

	public override func loadView() {
		self.view = TouchForwardingView(frame: UIScreen.main.bounds)
		self.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		if let parentView = self.presentingViewController?.view {
			(view as? TouchForwardingView)?.passthroughViews.append(parentView)
		}

		//Pan
		let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
		sheet.addGestureRecognizer(pan)

		//Sheet
		sheet.frame = CGRect(x: 0.0, y: view.bounds.height, width: view.bounds.width, height: view.bounds.height)
		view.addSubview(sheet)

		//LayoutGuide
		view.addLayoutGuide(sheetLayoutGuide)
		addSheetLayoutGuideConstraints(sheetLayoutGuide, view)

		//Physics
		animator.addBehavior(slideAlongYAxis)
		slideAlongYAxis.addChildBehavior(snap)
		snap.action = { [weak self] in
			guard let `self` = self else { return }
			guard self.state != .dismissing else { return }
			self.didUpdateSheetOriginTop?(self.sheet.frame.origin.y)
		}
	}

	public override func show(_ vc: UIViewController, sender: Any?) {
		super.show(vc, sender: sender)
		viewController = vc
	}

	public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		sheet.frame.size = size
	}

	@objc private func didPan(_ gesture: UIPanGestureRecognizer) {
		switch gesture.state {
		case .changed:
			//translation
			snap.snapPoint.y += gesture.translation(in: sheet.superview).y
			didUpdateSheetOriginTop?(sheet.frame.origin.y)
			gesture.setTranslation(.zero, in: sheet.superview)
			state = .moving
		case .ended:
			let velocity = gesture.velocity(in: sheet.superview)
			slideAlongYAxis.addLinearVelocity( CGPoint(x: 0.0, y: velocity.y), for: sheet)
			if velocity.y > 0 {
				//swiping down
				let locationY = gesture.location(in: sheet.superview).y
				let maxY = sheetLayoutGuide.layoutFrame.maxY
				let isTouchPointBelowClosedGuide = locationY > maxY
				if  isTouchPointBelowClosedGuide {
					dismiss(animated: true, completion: nil)
					state = .dismissing
					didUpdateSheetOriginTop?(view.bounds.size.height)
					return
				} else {
					snap.snapPoint.y = maxY
					state = .closed
				}
			} else {
				//swiping up
				snap.snapPoint.y = sheetLayoutGuide.layoutFrame.minY
				state = .open
			}
			didUpdateSheetOriginTop?(sheet.frame.origin.y)
		default:
			break
		}
	}

	private func removeOld(_ childViewController: UIViewController?) {
		guard let childViewController = childViewController else { return }
		willMove(toParentViewController: nil)
		childViewController.view.removeFromSuperview()
		childViewController.removeFromParentViewController()
	}

	private func embedNew(_ childViewController: UIViewController?) {
		guard let childViewController = childViewController else { return }
		childViewController.willMove(toParentViewController: self)
		addChildViewController(childViewController)
		childViewController.view.frame = sheet.bounds
		sheet.addSubview(childViewController.view)
		childViewController.didMove(toParentViewController: self)
	}
}

private class TouchForwardingView: UIView {
	var passthroughViews: [UIView] = []

	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		guard let hitView = super.hitTest(point, with: event) else { return nil }
		guard hitView == self else { return hitView }

		for passthroughView in passthroughViews {
			let point = convert(point, to: passthroughView)
			if let passthroughHitView = passthroughView.hitTest(point, with: event) {
				return passthroughHitView
			}
		}

		return self
	}
}
