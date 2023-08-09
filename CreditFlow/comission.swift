//
//  comission.swift
//  CreditFlow
//
//  Created by Никита Кобик on 08.08.2023.
//

import Foundation

enum Comission: String, CaseIterable, Identifiable {
    case percent, fee
    var id: Self { self }
}
