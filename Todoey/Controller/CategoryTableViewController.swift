//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Roman Hural on 10.02.2023.
//

import UIKit
import RealmSwift

// MARK: - CategoryTableViewController
class CategoryTableViewController: UITableViewController {
    
    // MARK: - Private Properties
    private var categories: Results<Category>?
    let realm = try! Realm()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    // MARK: - TableView Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? .zero
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories added yet"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let categories = categories else { return }
        if editingStyle == .delete {
            do {
                try realm.write {
                    realm.delete(categories[indexPath.row])
                }
            } catch {
                print("Error deleting category: \(error)")
            }
        }
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
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
            print("Saving categories error \(error)")
        }
        tableView.reloadData()
    }
    
    // MARK: - Action
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        var textField = UITextField()
        let addAction = UIAlertAction(title: "Add", style: .default) { action in
            let newCategory = Category()
            
            guard let textFieldText = textField.text else { return }
            newCategory.name = textFieldText
            
            self.save(category: newCategory)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        present(alert, animated: true)
    }
}
