//
//  Person.swift
//  CloudAula
//
//  Created by Andre Machado Parente on 01/02/17.
//  Copyright © 2017 Andre Machado Parente. All rights reserved.
//

import Foundation
import CloudKit

var globalContacts: [Contact] = []

class Contact: NSObject {
    var name: String!
    var idade: Int!
    var telephones: [TelephoneNumber] = []
    var references: [CKReference] = []
    init(name: String, idade: Int) {
        self.name = name
        self.idade = idade
    }
    
    init(name: String, idade: Int, telephones: [TelephoneNumber]) {
        self.name = name
        self.idade = idade
        self.telephones = telephones
    }
    
    func addTelephone(telephone: TelephoneNumber) {
        self.telephones.append(telephone)
    }
}
