//
//  Item.swift
//  Todoey
//
//  Created by Roman Hural on 11.02.2023.
//

import Foundation
import RealmSwift

class Item: Object {
    @Persisted var title: String = ""
    @Persisted var done: Bool = false
    @Persisted var createdDate: Date?
    @Persisted(originProperty: "items") var parentCategory: LinkingObjects<Category>
}
