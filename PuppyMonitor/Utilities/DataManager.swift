//
//  DataManager.swift
//  PuppyMonitor
//
//  Created by Michael Otmanski on 3/30/18.
//  Copyright © 2018 Michael Otmanski. All rights reserved.
//

import CoreData
import Foundation
import UIKit

final class DataManager {

    lazy var context: NSManagedObjectContext?  = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }

        return appDelegate.persistentContainer.viewContext
    }()

    func getUser() -> UserProfile? {
        guard let context = context else { return nil }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserProfile")

        do {
            if let fetchedUser = try context.fetch(fetchRequest).first as? UserProfile {
                return fetchedUser
            } else {
                return nil
            }
        } catch (let error) {
            print(error)
            return nil
        }
    }

    func updateUser(dogName: String?, imageData: Data?) {
        guard let context = context else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserProfile")

        do {
            if let fetchedUser = try context.fetch(fetchRequest).first as? NSManagedObject {
                //update existing user
                fetchedUser.setValue(dogName, forKey: "dogName")
                fetchedUser.setValue(imageData, forKey: "dogPhoto")
            } else {
                //create new user
                let user = NSEntityDescription.insertNewObject(forEntityName: "UserProfile", into: context)
                user.setValue(dogName, forKey: "dogName")
                user.setValue(imageData, forKey: "dogPhoto")
            }
            
            try context.save()
        } catch (let error) {
            print(error)
        }
    }
    
    func getRecordings() -> [String] {
        var recordings: [String] = []
        let docsURL = FileManager.documentsDirectory()
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: docsURL, includingPropertiesForKeys: nil, options: [])
            for url in contents {
                recordings.append(url.lastPathComponent)
            }
        } catch {
            print("error")
        }
        
        return recordings
    }
}
