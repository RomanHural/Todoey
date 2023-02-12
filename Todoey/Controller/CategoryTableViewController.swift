//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Roman Hural on 10.02.2023.
//

import UIKit
import RealmSwift
import ChameleonFramework

// MARK: - CategoryTableViewController
class CategoryTableViewController: SwipeTableViewController {
    
    // MARK: - Private Properties
    private let segueID: String = "goToItems"
    private let placeholder: String = "Create new category"
    private let rowHeight: CGFloat = 80
    private let emptyString: String = ""
    private let textFieldPlaceHolder = "Create new category"
    private let hexValue: String = "59ABE1"
    private let realm = try! Realm()
    private var categories: Results<Category>?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        guard let originalColor = UIColor(hexString: hexValue) else { return }
        navigationController?.navigationBar.backgroundColor = originalColor
        navigationController?.navigationBar.tintColor = FlatWhite()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: FlatWhite()]
    }
    
    private func setupTableView() {
        tableView.rowHeight = rowHeight
        tableView.separatorStyle = .none
    }
    
    // MARK: - TableView Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? .zero
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            guard let color = UIColor(hexString: category.hexValueColor) else { fatalError() }
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueID, sender: self)
    }
    
    // MARK: - PrepareForSegue Method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    // MARK: - Deleting Model Method
    override func deleteModel(at indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(category)
                }
            } catch {
                print(Error.deletingCategoryError, error)
            }
        }
    }
    
    // MARK: - Private Methods
    private func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    private func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print(Error.savingCategoryError, error)
        }
        tableView.reloadData()
    }
    
    // MARK: - Action
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: Title.addNewCategory, message: emptyString, preferredStyle: .alert)
        var textField = UITextField()
        let addAction = UIAlertAction(title: Title.addTitle, style: .default) { action in
            let newCategory = Category()
            
            newCategory.name = textField.hasText ? textField.text! : Title.defaulotCategoryTitle
            newCategory.hexValueColor = RandomFlatColor().hexValue()
            
            self.save(category: newCategory)
        }
        let cancelAction = UIAlertAction(title: Title.cancelTitle, style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = self.placeholder
            textField = alertTextField
        }
        present(alert, animated: true)
    }
}

