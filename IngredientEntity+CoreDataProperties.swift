//
//  IngredientEntity+CoreDataProperties.swift
//  Listora-IOS
//
//  Created by Alejandro on 04/06/25.
//
//

import Foundation
import CoreData


extension IngredientEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<IngredientEntity> {
        return NSFetchRequest<IngredientEntity>(entityName: "IngredientEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var quantity: Double
    @NSManaged public var unit: String?
    @NSManaged public var price: Double
    @NSManaged public var isPurchased: Bool
    @NSManaged public var list: ShoppingListEntity?

}

extension IngredientEntity : Identifiable {

}
