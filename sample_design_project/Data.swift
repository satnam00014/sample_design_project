//
//  Data.swift
//  sample_design_project
//
//  Created by SatnamSingh on 25/05/21.
//

import Foundation
import CoreData
import UIKit

class Data {
    private static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private static var folders : [Folder] = [Folder]()
    private static var notes : [Note] = [Note]()
    
    private static func deleteData(){
        let request : NSFetchRequest<Folder> = Folder.fetchRequest()
        var folderlist : [Folder] = [Folder]()
        do {
            //following is to fetch all providers
            folderlist = try context.fetch(request)
            //following loop is to delete all the providers
            for folder in folderlist {
                context.delete(folder)
                try context.save()
            }
        } catch  {
            print(error)
        }
    }
    
    static func createInitialData(){
        deleteData()
        createFolder()
        notes = [Note(context: context),Note(context: context),Note(context: context),Note(context: context),Note(context: context),Note(context: context),Note(context: context),Note(context: context)]
        
        //Following is data of notes
        notes[0].title = "Macbook Pro"
        notes[0].detail = "Premium Product with m1 Chip set"
        notes[0].date = Date()
        notes[0].parentFolder = folders[0]
        
        notes[1].title = "iPad Pro"
        notes[1].detail = "Pressure sensitive pencil with fast processor"
        notes[1].date = Date()
        notes[1].parentFolder = folders[0]
        
        notes[2].title = "iPhone XR"
        notes[2].detail = "Face recognition feature A12 Bionic"
        notes[2].date = Date()
        notes[2].parentFolder = folders[0]
        
        notes[3].title = "iPhone 11"
        notes[3].detail = "Dual camera with A13 Bionic"
        notes[3].date = Date()
        notes[3].parentFolder = folders[0]
        
        notes[4].title = "Microsoft Surface Pro 7"
        notes[4].detail = "Touch screen with Core i7"
        notes[4].date = Date()
        notes[4].parentFolder = folders[1]
        
        notes[5].title = "Microsoft Surface Pro X"
        notes[5].detail = "Touch screen with 15 hours of barttery and 128 gb ssd"
        notes[5].date = Date()
        notes[5].parentFolder = folders[1]
        
        notes[6].title = "Microsoft Surface Pro 6"
        notes[6].detail = "Core i7 and 256 HDD"
        notes[6].date = Date()
        notes[6].parentFolder = folders[1]
        
        notes[7].title = "Asus ROG Zephyrus S17"
        notes[7].detail = "RTX 3080 and 2TB SSD"
        notes[7].date = Date()
        notes[7].parentFolder = folders[2]
        do {
            try context.save()
        } catch  {
            print(error)
        }
    }
    
    private static func createFolder(){
        //First folder
        var folder = Folder(context: context)
        folders.append(folder)
        folder.name = "Apple"
        
        //second folder
        folder = Folder(context: context)
        folders.append(folder)
        folder.name = "Microsoft"
        
        //Third folder
        folder = Folder(context: context)
        folders.append(folder)
        folder.name = "Asus"
        do {
            try context.save()
        } catch  {
            print(error)
        }
    }
}
