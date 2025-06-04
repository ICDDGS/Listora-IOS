//
//  ShoppingListDataManager.swift
//  Listora-IOS
//
//  Created by Alejandro on 04/06/25.
//

import Foundation
import CoreData
import UIKit

class ShoppingListDataManager{
    
    static let shared = ShoppingListDataManager()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Create
    func createList(name: String, budget: Double, dete: Date){
        let newList = ShoppingListEntity(context: context)
        newList.name = name
        newList.budget = budget
        newList.date = dete
        saveContext()
    }
    
    //Read
    func fetchLists() -> [ShoppingListEntity]{
        let request: NSFetchRequest<ShoppingListEntity> = ShoppingListEntity.fetchRequest()
        do{
            return try context.fetch(request)
        }catch{
            print("Error al obtener listas \(error)")
            return []
        }
    }
    
    //Update
    func updateList(_ list: ShoppingListEntity, name: String, budget: Double, date: Date){
        list.name = name
        list.budget = budget
        list.date = date
        saveContext()
    }
    
    //Delete
    func deleteList(_ list:ShoppingListEntity){
        context.delete(list)
        saveContext()
    }
    
    private func saveContext(){
        do{
            try context.save()
        }catch{
            print("Error al guardar contexto: \(error)")
        }
    }
    
}

