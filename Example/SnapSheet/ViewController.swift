//
//  ViewController.swift
//  SnapSheet
//
//  Created by Dwayne Coussement on 08/17/2018.
//  Copyright (c) 2018 Dwayne Coussement. All rights reserved.
//

import UIKit
import SnapSheet

class ViewController: UIViewController {

	@IBOutlet weak var fabBottomConstraint: NSLayoutConstraint!
	private let tableVC = SnapSheetTableViewController(style: .plain)

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let destination = segue.destination as? SnapSheetViewController else { return }
		tableVC.tableView.isScrollEnabled = false
		destination.viewController = tableVC

		destination.didUpdateSheetOriginTop = { [weak self] (newTop) in
			guard let `self` = self else { return }
			let originY = self.view.frame.height - newTop
			self.fabBottomConstraint.constant = originY
		}
	}
}

