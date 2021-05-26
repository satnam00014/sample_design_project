//
//  MainTableViewController.swift
//  sample_design_project
//
//  Created by SatnamSingh on 24/05/21.
//

import UIKit
import CoreData

class MainTableViewController: UITableViewController {
    @IBOutlet weak var createCategoryButton: UIBarButtonItem!
    private var editMode : Bool = false
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let searchController = UISearchController(searchResultsController: nil)
    private var folders : [Folder] = [Folder]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.title = "Folders"
        showSearchBar()
        InitialData.createInitialData()
        loadFolders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.navigationController?.toolbar.isHidden = false
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        editMode = !editMode
        createCategoryButton.isEnabled = !editMode
    }
    
    private func loadFolders(predicate : NSPredicate? = nil)  {
        let request : NSFetchRequest<Folder> = Folder.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        if predicate != nil {
            request.predicate = predicate
        }
        do {
            self.folders = try self.context.fetch(request)
        } catch  {
            print(error)
        }
    }
    
    private func deleteFolder(folder:Folder){
        do{
            context.delete(folder)
            try context.save()
        }catch{
            print(error)
        }
    }
    
    private func createFolder(name:String){
        let newFolder = Folder(context: context)
        folders.append(newFolder)
        newFolder.name = name
        do {
            try context.save()
        } catch  {
            print(error)
        }
    }
    
    @IBAction func createCategoryFunction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Create Category", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {field in field.placeholder = "Category Name"})
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: {
            _ in
            //following is to get name of categories in lower case
            let categoryNames = self.folders.map{$0.name?.lowercased()}
            guard let text = alert.textFields?.first?.text else{return}
            print(text)
            guard !categoryNames.contains(text) else {
                let alertMessage = UIAlertController(title: "Folder already exist", message: "", preferredStyle: .alert)
                alertMessage.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                self.present(alertMessage, animated: true, completion: nil)
                return
            }
            self.createFolder(name: text)
            self.loadFolders()
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "main_table_cell", for: indexPath)
        cell.textLabel?.text = "\(folders[indexPath.row].name ?? "")"
        cell.detailTextLabel?.text = "\(folders[indexPath.row].notes?.count ?? 0) - notes"
        cell.imageView?.image = UIImage(systemName: "folder")
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Are you sure?", message: "Delete note", preferredStyle: .actionSheet)
            let deleteButton = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.deleteFolder(folder: self.folders[indexPath.row])
                self.folders.remove(at: indexPath.row)
                self.tableView.reloadData()
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(deleteButton)
            alert.addAction(cancelButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destinationView = self.storyboard?.instantiateViewController(identifier: "NotesView") as! NotesViewController
        destinationView.parentFolder = folders[indexPath.row]
        self.navigationController?.pushViewController(destinationView, animated: true)
    }

}


//MARK: - search bar delegate methods
extension MainTableViewController: UISearchBarDelegate {

    func showSearchBar() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Category"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.searchTextField.textColor = .systemBlue
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text:String = searchBar.text!
        if text.count == 0 {
            self.loadFolders()
        }else{
            let predicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
            self.loadFolders(predicate: predicate)
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.loadFolders()
        self.tableView.reloadData()
    }
    
}
