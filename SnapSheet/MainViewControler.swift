//
//  MainViewControler.swift
//  SnapSheet
//
//  Created by Bram De Geyter on 10/08/2018.
//  Copyright © 2018 Palaplu. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    private let tableVC = SnapSheetTableViewController(style: .plain)
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? SnapSheetViewController else { return }
        destination.viewController = tableVC
    }
}
