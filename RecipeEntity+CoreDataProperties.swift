//
//  RecipeEntity+CoreDataProperties.swift
//  Listora-IOS
//
//  Created by Alejandro on 12/06/25.
//
//

import Foundation
import CoreData


extension RecipeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecipeEntity> {
        return NSFetchRequest<RecipeEntity>(entityName: "RecipeEntity")
    }

    @NSManaged public var descript: String?
    @NSManaged public var name: String?
    @NSManaged public var steps: String?
    @NSManaged public var ingredient: NSSet?

}

// MARK: Generated accessors for ingredient
extension RecipeEntity {

    @objc(addIngredientObject:)
    @NSManaged public func addToIngredient(_ value: RecipeIngEntity)

    @objc(removeIngredientObject:)
    @NSManaged public func removeFromIngredient(_ value: RecipeIngEntity)

    @objc(addIngredient:)
    @NSManaged public func addToIngredient(_ values: NSSet)

    @objc(removeIngredient:)
    @NSManaged public func removeFromIngredient(_ values: NSSet)

}

extension RecipeEntity : Identifiable {

}
