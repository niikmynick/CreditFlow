//
//  Creditor.swift
//  CreditFlow
//
//  Created by Никита Кобик on 08.08.2023.
//

import Foundation


struct Creditor: Identifiable {
    var id = UUID()
    var name: String
    var value: Double?
    var com_type: Comission
    var percentOrFee: Double?
    
    init(name: String, value: Double?, com_type: Comission, percentOrFee: Double?) {
        self.name = name
        self.value = value
        self.com_type = com_type
        self.percentOrFee = percentOrFee
    }
}
