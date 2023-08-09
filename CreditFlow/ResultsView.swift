//
//  ResultView.swift
//  CreditFlow
//
//  Created by Никита Кобик on 08.08.2023.
//

import SwiftUI


struct ResultsView: View {
    @Binding var creditors: [Creditor]
    @Binding var cash: Double?
    @Binding var showingResults: Bool
    
    @Binding var total_creditorsGet: Double
    @Binding var debt_sum: Double
    @Binding var ratio: [String:Double]
    @Binding var creditorsGet: [String: Double]
    @Binding var bankPayments: [String: Double]
    @Binding var totalFees: [String: Double]
    
    
    var body: some View {
        
        HStack {
            Button("Закрыть") {
                showingResults = false // Set the isPresented property to false to close the sheet
            }
            
            Spacer()
        }
        .padding()
        
        List {
            Section(header: Text("Результаты")) {}
            
            Section(header: Text("Суммы и доли")) {
                Text("Сумма требований: \(debt_sum.formatted(.number))")
                Text("Сумма средств к распределению: \(cash!.formatted(.number))")
                Text("Сумма погашения требований: \(total_creditorsGet.rounded(toPlaces: 2).formatted(.number))")
            }

            Section(header: Text("Доли кредиторов")) {
                ForEach(ratio.sorted(by: <), id: \.key) { key, value in
                    Text("\(key): \(value.rounded(toPlaces: 4).formatted(.percent))")
                }
            }

            Section(header: Text("Размеры погашения требований")) {
                ForEach(creditorsGet.sorted(by: <), id: \.key) { key, value in
                    Text("\(key): \(value.rounded(toPlaces: 2).formatted(.number))")
                }
            }

            Section(header: Text("Размеры комиссий")) {
                ForEach(totalFees.sorted(by: <), id: \.key) { key, value in
                    Text("\(key): \(value.rounded(toPlaces: 2).formatted(.number))")
                }
            }

            Section(header: Text("Переводы с учетом комиссий")) {
                ForEach(bankPayments.sorted(by: <), id: \.key) { key, value in
                    Text("\(key): \(value.rounded(toPlaces: 2).formatted(.number))")
                }
            }
        }
        .listStyle(.plain)
        .padding()
        .frame(minWidth: 640, minHeight: 360)
    }
}
