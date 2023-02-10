//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Roman Hural on 10.02.2023.
//

import UIKit
import CoreData

// MARK: - CategoryTableViewController
class CategoryTableViewController: UITableViewController {
    
    // MARK: - Private Properties
    private var categoryArray: [Category] = []
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    // MARK: - TableView Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let item = categoryArray[indexPath.row]
        if editingStyle == .delete {
            context.delete(item)
            categoryArray.remove(at: indexPath.item)
            saveCategories()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    // MARK: - Private Methods
    private func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Loading categories error \(error)")
        }
        tableView.reloadData()
    }
    
    private func saveCategories() {
        do {
            try context.save()
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
            let category = Category(context: self.context)
            
            guard let textFieldText = textField.text else { return }
            category.name = textFieldText
            
            self.categoryArray.append(category)
            self.saveCategories()
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
