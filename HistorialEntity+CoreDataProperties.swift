//
//  HistorialEntity+CoreDataProperties.swift
//  Listora-IOS
//
//  Created by Alejandro on 04/06/25.
//
//

import Foundation
import CoreData


extension HistorialEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistorialEntity> {
        return NSFetchRequest<HistorialEntity>(entityName: "HistorialEntity")
    }

    @NSManaged public var date: Date?
    @NSManaged public var name: String?
    @NSManaged public var price: Double
    @NSManaged public var quantity: Double
    @NSManaged public var unit: String?

}

extension HistorialEntity : Identifiable {

}
