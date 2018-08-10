//
//  SnapSheetTableViewController.swift
//  SnapSheet
//
//  Created by Bram De Geyter on 07/08/2018.
//  Copyright © 2018 Palaplu. All rights reserved.
//

import UIKit

class SnapSheetTableViewController: UITableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}
