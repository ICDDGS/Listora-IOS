//
//  ShoppingListEntity+CoreDataProperties.swift
//  Listora-IOS
//
//  Created by Alejandro on 04/06/25.
//
//

import Foundation
import CoreData


extension ShoppingListEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShoppingListEntity> {
        return NSFetchRequest<ShoppingListEntity>(entityName: "ShoppingListEntity")
    }

    @NSManaged public var budget: Double
    @NSManaged public var date: Date?
    @NSManaged public var name: String?
    @NSManaged public var ingredients: NSSet?

}

// MARK: Generated accessors for ingredients
extension ShoppingListEntity {

    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: IngredientEntity)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: IngredientEntity)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)

}

extension ShoppingListEntity : Identifiable {

}
