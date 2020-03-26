//
//  Restaurant.swift
//  Grumble
//
//  Created by Allen Chang on 3/21/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

struct RestaurantList: Decodable{
    var list: [Restaurant]
}

struct Restaurant: Decodable, Identifiable{
    var id: String
    var address: String?
    var food: String?
    var price: Double?
}
