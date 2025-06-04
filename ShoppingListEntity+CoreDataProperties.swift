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

}

extension ShoppingListEntity : Identifiable {

}
