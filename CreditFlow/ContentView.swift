//
//  ContentView.swift
//  CreditFlow
//
//  Created by Никита Кобик on 02.08.2023.
//

import SwiftUI


struct ContentView: View {
    @State private var cash: Double? = 14000
    @State private var creditors: [Creditor] = [
        Creditor(name: "Альфа", value: 14000, com_type: .percent, percentOrFee: 3),
        Creditor(name: "Сбер", value: 5000, com_type: .fee, percentOrFee: 360),
        Creditor(name: "ВТБ", value: 3000, com_type: .percent, percentOrFee: 5)
    ]
    @State private var showingResults = false
    
    @State var debt_sum: Double = 0
    @State var total_creditorsGet: Double = 0
    @State var ratio: [String:Double] = [:]
    @State var creditorsGet: [String: Double] = [:]
    @State var bankPayments: [String: Double] = [:]
    @State var totalFees: [String: Double] = [:]
    
    @State private var isErrorShown = false
    @State private var errorMessage = ""
    
        
    private func addCreditor() {
        creditors.append(Creditor(name: "", value: 0, com_type: .percent, percentOrFee: 0))
    }
    
    private func deleteCreditor(at index: Int) {
        creditors.remove(at: index)
    }
    
    private func clearAll() {
        cash = nil
        creditors = []
    }
    
    private func validate() -> Bool {

//        at least one creditor
        if creditors.count == 0 {
            errorMessage = "Не добавлено ни одного кредитора"
            return false
        }

//        cash below 0
        if cash! < 0 {
            errorMessage = "Конкурсная масса не может быть менее \(0.formatted(.number))"
            return false
        }
        
        for creditor in creditors {
            
//            all info about creditors
            if creditor.name.isEmpty {
                errorMessage = "Для некоторых кредиторов отсутствует необходимая информация"
                return false
            }
            
//            percents above 100
            if creditor.com_type == .percent {
                if creditor.percentOrFee > 100 {
                    errorMessage = "Комиссия для перевода кредитору \(creditor.name) превышает допустимое значение в \(100.formatted(.percent))"
                    return false
                }
                if creditor.percentOrFee < 0 {
                    errorMessage = "Комиссия для перевода кредитору \(creditor.name) ниже допустимого значения в \(0.formatted(.percent))"
                    return false
                }
            }
            
//            too low debt
            if creditor.value < 0 {
                errorMessage = "Долг кредитору \(creditor.name) не может быть менее \(0.formatted(.number))"
                return false
            }
        }
        
        return true
    }
    
    private func calculate() {
        
//        for i in 0...creditors.count - 1 {
//            print(creditors[i])
//        }
        
//      clear previous data
        total_creditorsGet = 0
        debt_sum = 0
        ratio = [:]
        creditorsGet = [:]
        bankPayments = [:]
        totalFees = [:]
        
//      init
        var debts: [String?:Double] = [:]
        var conds:[String?:Bool] = [:]
        var fees: [String?:Double] = [:]

        for i in creditors {
            debts[i.name] = i.value
            if i.com_type == .percent {
                conds[i.name] = true
            } else {
                conds[i.name] = false
            }
            
            fees[i.name] = i.percentOrFee
        }

//      sum of all debts
        for i in debts.values {
            debt_sum += i
        }
        
//      setting ratio of every creditor demand to persons cash
        for name in debts.keys {
            ratio[name!] = debts[name]! / debt_sum
        }

//      sum of all non percentage fees
        var sum_fee: Double = 0
        
//      sum of all percentage fees
        var sum_percent: Double = 100
        
        for name in conds.keys {
            if conds[name] == false {
                sum_fee += fees[name]!
            } else {
                sum_percent += ratio[name!]! * fees[name!]!
            }
        }
        
//      cash after fees payment
        var remaining_cash: Double
        
        if sum_fee > cash! {
            remaining_cash = 0
        } else {
            remaining_cash = cash! - sum_fee
        }

//      calculate info for printing
        for name in ratio.keys {
            let temp = remaining_cash / sum_percent * ratio[name]! * 100
            creditorsGet[name] = temp
            total_creditorsGet += temp
            if conds[name] == true {
                bankPayments[name] = temp + temp / 100 * fees[name]!
                totalFees[name] = temp / 100 * fees[name]!
            } else {
                bankPayments[name] = temp + fees[name]!
                totalFees[name] = fees[name]!
            }
        }
        
    }

    var body: some View {
            VStack(spacing: 20) {
                Text("CreditFLow")
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack {
                    Text("Размер конкурсной массы")
                    TextField("Размер конкурсной массы должника", value: $cash, format: .number)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)
                
                HStack(spacing: 20) {
                    Button("Добавить кредитора") {
                        addCreditor()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    
                    Button("Рассчитать") {
                        if validate() {
                            calculate()
                            showingResults = true
                        } else {
                            isErrorShown = true
                        }
                        
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .alert(isPresented: $isErrorShown) {
                        Alert(
                            title: Text("Ошибка"),
                            message: Text(errorMessage),
                            dismissButton: .default(Text("Исправить"))
                        )
                    }
                    
                    Button("Очистить все") {
                        clearAll()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                .padding(.bottom)
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(minimum: 200), spacing: 20),
                        GridItem(.flexible(minimum: 200), spacing: 20),
                        GridItem(.flexible(minimum: 200), spacing: 20),
                    ], spacing: 20) {
                        ForEach(creditors.indices, id: \.self) { index in
                            VStack {
                                HStack {
                                    Text("Имя кредитора")
                                    Spacer()
                                    TextField("Имя кредитора", text: $creditors[index].name, onCommit: {
                                        DispatchQueue.main.async {
                                            NSApp.keyWindow?.makeFirstResponder(nil)
                                        }
                                        
                                    }
                                    )
                                        .textFieldStyle(.roundedBorder)
                                }
                                .padding(.horizontal)
                                .multilineTextAlignment(.leading)
                                
                                HStack {
                                    Text("Сумма долга")
                                    TextField("Сумма долга", value: $creditors[index].value, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                }
                                .padding(.horizontal)
                                
                                Picker("Вид комиссии", selection: $creditors[index].com_type) {
                                    Text("Процент").tag(Comission.percent)
                                    Text("Фиксированная плата").tag(Comission.fee)
                                }
                                .pickerStyle(.segmented)
                                
                                if creditors[index].com_type == .percent {
                                    HStack {
                                        Text("Проценты")
                                        TextField("Проценты", value: $creditors[index].percentOrFee, format: .number)
                                            .textFieldStyle(.roundedBorder)
                                    }
                                    .padding(.horizontal)
                                } else {
                                    HStack {
                                        Text("Сумма")
                                        TextField("Сумма", value: $creditors[index].percentOrFee, format: .number)
                                            .textFieldStyle(.roundedBorder)
                                    }
                                    .padding(.horizontal)
                                }
                                
                                Button("Удалить", action: { deleteCreditor(at: index) })
                                    .buttonStyle(.borderedProminent)
                                    .tint(.red)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray))
                        }
                    }
                    .padding()
                }
            }
            .padding()
            .frame(minWidth: 1280, idealWidth: 1440, minHeight: 720, idealHeight: 900)
            .sheet(isPresented: $showingResults) {
                ResultsView(creditors: $creditors,
                                  cash: $cash,
                                  showingResults: $showingResults,
                                  total_creditorsGet: $total_creditorsGet,
                                  debt_sum: $debt_sum,
                                  ratio: $ratio,
                                  creditorsGet: $creditorsGet,
                                  bankPayments: $bankPayments,
                                  totalFees: $totalFees
                )
            }
        }
    }


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
