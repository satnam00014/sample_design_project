//
//  NotesViewController.swift
//  sample_design_project
//
//  Created by SatnamSingh on 24/05/21.
//

import UIKit
import CoreData

class NotesViewController: UITableViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var optionButton: UIBarButtonItem!
    @IBOutlet weak var moveButton: UIBarButtonItem!
    @IBOutlet weak var plusButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    var editMode : Bool = false
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let searchController = UISearchController(searchResultsController: nil)
    
    private var notes : [Note] = [Note]()
    var parentFolder : Folder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSearchBar()
        self.navigationItem.title = parentFolder?.name
        loadNotes()
    }

    func deleteNote(note:Note)  {
        do {
            context.delete(note)
            try context.save()
        } catch  {
            print(error)
        }
    }
    
    func loadNotes(predicate : NSPredicate? = nil,search: [NSSortDescriptor]?=nil)  {
        let request : NSFetchRequest<Note> = Note.fetchRequest()
        if search != nil{
            request.sortDescriptors = search
        }else{
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        }
        let folderPredicate = NSPredicate(format: "parentFolder.name=%@", parentFolder!.name!)
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [folderPredicate, additionalPredicate])
        } else {
            request.predicate = folderPredicate
        }
        do {
            self.notes = try self.context.fetch(request)
        } catch  {
            print(error)
        }
    }
    
    
    @IBAction func editFunction(_ sender: UIBarButtonItem) {
        editMode = !editMode
        enableSelection(editMode: editMode)
    }
    
    func enableSelection(editMode : Bool)  {
        if editMode {
            editButton.title = "Done"
        }else{
            editButton.title = "Edit"
        }
        self.navigationItem.setHidesBackButton(editMode, animated: true)
        deleteButton.isEnabled = editMode
        moveButton.isEnabled = editMode
        plusButton.isEnabled = !editMode
        optionButton.isEnabled = !editMode
        self.tableView.allowsMultipleSelectionDuringEditing = editMode
        self.tableView.setEditing(editMode, animated: true)
    }
    
    @IBAction func optionButtonFunction(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "SORT", message: "Notes", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "(A-Z) Ascending", style: .default, handler: {
            _ in
            self.loadNotes(predicate: nil, search: [NSSortDescriptor(key: "title", ascending: true)])
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "(A-Z) Descending", style: .default, handler: {
            _ in
            self.loadNotes(predicate: nil, search: [NSSortDescriptor(key: "title", ascending: false)])
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Date Ascending", style: .default, handler: {
            _ in
            self.loadNotes(predicate: nil, search: [NSSortDescriptor(key: "date", ascending: true)])
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Date Descending", style: .default, handler: {
            _ in
            self.loadNotes(predicate: nil, search: [NSSortDescriptor(key: "date", ascending: false)])
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteFunction(_ sender: UIBarButtonItem) {
        if let indexPaths = self.tableView.indexPathsForSelectedRows {
            let alert = UIAlertController(title: "Delete notes", message: "Are you sure?", preferredStyle: .actionSheet)
            let deleteButton = UIAlertAction(title: "Delete", style: .destructive, handler:{ _ in
                let rows = (indexPaths.map {$0.row}).sorted(by: >)
                let _ = rows.map {self.deleteNote(note: self.notes[$0])}
                self.loadNotes()
                self.tableView.reloadData()
                self.editMode = !self.editMode
                self.enableSelection(editMode: self.editMode)
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(deleteButton)
            alert.addAction(cancelButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func moveFunction(_ sender: UIBarButtonItem) {
        if let indexPaths = self.tableView.indexPathsForSelectedRows{
            let rows = indexPaths.map{$0.row}
            let destinationView = self.storyboard?.instantiateViewController(identifier: "move_note_view") as! MoveNotesController
            destinationView.selectedNotes = rows.map{notes[$0]}
            destinationView.delegate = self
            self.present(destinationView, animated: true, completion: nil)
        }
    }
    
    @IBAction func createNoteFunction(_ sender: UIBarButtonItem) {
        let destination = self.storyboard?.instantiateViewController(identifier: "create_note_view") as! CreateNoteViewController
        destination.parentFolder = self.parentFolder
        destination.delegate = self
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notes_cell", for: indexPath)
        cell.textLabel?.text = "\(notes[indexPath.row].title ?? "")"
        cell.detailTextLabel?.text = "Date:- \(Date.getDateWithFormat(date: notes[indexPath.row].date ?? Date()))"
        cell.imageView?.image = UIImage(systemName: "pencil")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Delete", message: "Are you sure to delete note ?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
                _ in
                self.deleteNote(note: self.notes[indexPath.row])
                self.loadNotes()
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !editMode else { return }
        let destinationView = self.storyboard?.instantiateViewController(identifier: "edit_note_view") as! EditNoteViewController
        destinationView.delegate = self
        destinationView.note = notes[indexPath.row]
        self.navigationController?.pushViewController(destinationView, animated: true)
    }

}


//MARK: - search bar delegate methods
extension NotesViewController : UISearchBarDelegate {

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
            self.loadNotes()
        }else{
            //following is to filter notes with title or detail
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR detail CONTAINS[cd] %@", argumentArray: [text,text])
            self.loadNotes(predicate: predicate)
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
       self.loadNotes()
        self.tableView.reloadData()
    }
    
}

extension Date {

     static func getDateWithFormat(date : Date) -> String {

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "dd/MM/yyyy, hh:mm a"

        return dateFormatter.string(from: date)
    }
}
