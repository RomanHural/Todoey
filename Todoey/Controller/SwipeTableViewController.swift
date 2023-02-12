//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Roman Hural on 12.02.2023.
//

import UIKit
import SwipeCellKit

// MARK: - SwipeTableViewController
class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    // MARK: - Private Properties
    private let cellID: String = "Cell"
    private let deleteIconString: String = "delete-icon"
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - TableView Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = UIColor.tintColor
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: Title.deleteTitle) { action, indexPath in
            self.deleteModel(at: indexPath)
        }
        deleteAction.image = UIImage(named: deleteIconString)
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    // MARK: - Public Method
    func deleteModel(at indexPath: IndexPath) {}
}
