//
//  ViewController.swift
//  Todoey
//
//  Created by Roman Hural on 06.02.2023.
//

import UIKit
import RealmSwift
import ChameleonFramework

// MARK: - ToDoListTableViewController
class ToDoListTableViewController: SwipeTableViewController {
    
    // MARK: - Outlet
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Private Property
    private let rowHeight: CGFloat = 65
    private let keyPath: String = "createdDate"
    private let emptyString: String = ""
    private let placeholder: String = "Create new item"
    private let predicateFormat: String = "title CONTAINS[cd] %@"
    private let realm = try! Realm()
    private var todoItems: Results<Item>?
    
    // MARK: - Public Property
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(withCategory: selectedCategory)
        setupSearchBar(withColor: selectedCategory)
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar(withCategory selectedCategory: Category?) {
        guard let selectedCategory = selectedCategory,
              let color = UIColor(hexString: selectedCategory.hexValueColor) else { return }
        navigationController?.navigationBar.backgroundColor = color
        navigationController?.navigationBar.tintColor = ContrastColorOf(color, returnFlat: true)
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:
                                                                            ContrastColorOf(color, returnFlat: true)]
        title = selectedCategory.name
    }
    
    private func setupSearchBar(withColor color: Category?) {
        guard let selectedCategory = selectedCategory,
              let color = UIColor(hexString: selectedCategory.hexValueColor) else { return }
        searchBar.barTintColor = color
        searchBar.searchTextField.backgroundColor = .white
    }
    
    private func setupTableView() {
        tableView.rowHeight = rowHeight
    }
    
    // MARK: - Table View Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? .zero
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            if let colour = UIColor(hexString: selectedCategory!.hexValueColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            cell.textLabel?.text = item.title
            cell.accessoryType = !item.done ? .none : .checkmark
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print(Error.updatingItemError, error)
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Deleting Model Method
    override func deleteModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print(Error.deletingItemError,error)
            }
        }
    }
    
    // MARK: - Private Methods
    private func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: keyPath, ascending: true)
        self.tableView.reloadData()
    }
    
    // MARK: - Action
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: Title.addNewItem, message: emptyString, preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction(title: Title.addTitle, style: .default) { action in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.hasText ? textField.text! : Title.defaultItemTitle
                        newItem.createdDate = Date.now
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print(Error.savingItemError, error)
                }
            }
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: Title.cancelTitle, style: .cancel)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = self.placeholder
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension ToDoListTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter(predicateFormat, searchBar.text!).sorted(byKeyPath: keyPath, ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == .zero {
            loadItems()
            DispatchQueue.main.async { searchBar.resignFirstResponder() }
        }
    }
}
