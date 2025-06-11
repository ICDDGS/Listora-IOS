//
//  RecipeIngEntity+CoreDataProperties.swift
//  Listora-IOS
//
//  Created by Alejandro on 06/06/25.
//
//

import Foundation
import CoreData


extension RecipeIngEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecipeIngEntity> {
        return NSFetchRequest<RecipeIngEntity>(entityName: "RecipeIngEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var quantity: Double
    @NSManaged public var unit: String?
    @NSManaged public var recipe: RecipeEntity?

}

extension RecipeIngEntity : Identifiable {

}
