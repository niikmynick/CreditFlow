//
//  extension.swift
//  CreditFlow
//
//  Created by Никита Кобик on 08.08.2023.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
