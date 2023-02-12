//
//  Category.swift
//  Todoey
//
//  Created by Roman Hural on 11.02.2023.
//

import Foundation
import RealmSwift

class Category: Object {
    @Persisted var name: String = ""
    @Persisted var hexValueColor: String = ""
    @Persisted var items = List<Item>()
}
