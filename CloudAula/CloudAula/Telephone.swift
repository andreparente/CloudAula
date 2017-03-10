//
//  Address.swift
//  CloudAula
//
//  Created by Andre Machado Parente on 01/02/17.
//  Copyright © 2017 Andre Machado Parente. All rights reserved.
//

import Foundation

class Telephone: NSObject {
    var type: String!
    var number: Int!
    
    
    init(type: String, number: Int) {
        self.type = type
        self.number = number
    }
}
