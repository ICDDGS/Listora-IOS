//
//  RecipesListDataManager.swift
//  Listora-IOS
//
//  Created by Alejandro on 06/06/25.
//

import Foundation
import CoreData
import UIKit

class RecipesListDataManager{
    
    static let shared = RecipesListDataManager()
    private let context =
    (UIApplication.shared.delegate as! AppDelegate)
        .persistentContainer
        .viewContext
    
    //Create
    func createList(name: String, descript:String){
        let newList = RecipeEntity(context: context)
        newList.name = name
        newList.descript = descript
        saveContext()
        
    }
    
    //Read
    func fetchLists() -> [RecipeEntity]{
        let request: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        do{
            return try context.fetch(request)
        }catch{
            print("Error al obtener listas \(error)")
            return []
        }
    }
    
    //Update
    func updateList(_ list: RecipeEntity, name: String, descript: String){
        list.name = name
        list.descript = descript
    }
    
    //Delete
    func deleteList(_ list:RecipeEntity){
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
