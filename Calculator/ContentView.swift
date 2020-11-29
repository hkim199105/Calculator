//
//  ContentView.swift
//  Calculator
//
//  Created by Hakyoung Kim on 2020/11/29.
//

import SwiftUI

enum CalculatorButtonType: String {
    case number
    case symbol
    case decimal
    case equals
    case etc
}

enum CalculatorButton: String {
    case zero, one, two, three, four, five, six, seven, eight, nine
    case equals, plus, minus, multiply, divide
    case decimal
    case ac, plusMinus, percent
    
    var title: String {
        switch self {
        case .zero:         return "0"
        case .one:          return "1"
        case .two:          return "2"
        case .three:        return "3"
        case .four:         return "4"
        case .five:         return "5"
        case .six:          return "6"
        case .seven:        return "7"
        case .eight:        return "8"
        case .nine:         return "9"
        case .plus:         return "+"
        case .minus:        return "-"
        case .multiply:     return "x"
        case .divide:       return "÷"
        case .equals:       return "="
        case .decimal:      return "."
        case .plusMinus:    return "+/-"
        case .percent:      return "%"
        case .ac:           return "AC"
        }
    }
    
    var type: CalculatorButtonType {
        switch self {
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            return .number
        case .plus, .minus, .divide, .multiply:
            return .symbol
        case .decimal:
            return .decimal
        case .equals:
            return .equals
        default:
            return .etc
        }
    }
    
    var background: Color {
        switch self.type {
        case .number:
            return Color(.darkGray)
        case .symbol:
            return .orange
        case .decimal:
            return Color(.lightGray)
        case .equals:
            return Color(.lightGray)
        case .etc:
            return Color(.lightGray)
        }
    }
}

class GlobalEnvironment: ObservableObject {
    @Published var display = "0"
    var lastSymbol:CalculatorButton = .plus
    var lastElement = ""
    var mustInit = true
    
    func receiveInput(calculatorButton: CalculatorButton) {
        switch calculatorButton.type {
        case .number:
            if mustInit {
                self.display = calculatorButton.title
                mustInit = false
            } else {
                self.display = self.display + calculatorButton.title
            }
        case .decimal:
            self.display = self.display + calculatorButton.title
        case .symbol:
            if !lastElement.isEmpty && !mustInit {
                self.display = calculate(first: self.lastElement, second: self.display, symbol: self.lastSymbol)
            }
            self.lastElement = self.display
            self.lastSymbol = calculatorButton
            mustInit = true
        case .equals:
            if !mustInit {
                self.display = calculate(first: self.lastElement, second: self.display, symbol: self.lastSymbol)
            }
            self.lastSymbol = .plus
            self.lastElement = ""
            mustInit = true
        case .etc:
            if calculatorButton.title == "AC" {
                self.display = "0"
                self.lastElement = ""
                self.lastSymbol = .plus
            } else {
                self.display = self.display + calculatorButton.title
            }
        }
    }
    
    func calculate(first: String, second: String, symbol: CalculatorButton) -> String {
        let firstNum = NSString(string: first).doubleValue
        let secondNum = NSString(string: second).doubleValue

        switch symbol {
        case .plus: return String(describing: firstNum + secondNum)
        case .minus: return String(describing: firstNum - secondNum)
        case .multiply: return String(describing: firstNum * secondNum)
        case .divide: return String(describing: firstNum / secondNum)
        default: return ""
        }
    }
}

struct ContentView: View {
    
    @EnvironmentObject var env: GlobalEnvironment
    
    let buttons: [[CalculatorButton]] = [
        [.ac, .plusMinus, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .minus],
        [.one, .two, .three, .plus],
        [.zero, .decimal, .equals]
    ]
    
    var body: some View {
        ZStack(alignment:.bottom) {
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            VStack(spacing: 12) {
                HStack {
                    Spacer()
                    Text(env.display).foregroundColor(.white)
                        .font(.system(size:72))
                }.padding()
                
                ForEach(buttons, id: \.self) { buttons in
                    HStack {
                        ForEach(buttons, id: \.self) { button in
                            CalculatorButtonView(button: button)
                        }
                    }
                }
            }.padding(.bottom)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(GlobalEnvironment())
    }
}

struct CalculatorButtonView: View {
    
    var button: CalculatorButton
    @EnvironmentObject var env: GlobalEnvironment
    
    var body: some View {
        Button(action: {
            self.env.receiveInput(calculatorButton: button)
        }){
            Text(button.title)
                .font(.system(size: 32))
                .foregroundColor(.white)
                .frame(width: self.buttonWidth(button: button), height: (UIScreen.main.bounds.width - 5 * 12) / 4)
                .background(button.background)
                .cornerRadius(buttonWidth(button: button) / 2)
        }
    }
    
    private func buttonWidth(button: CalculatorButton) -> CGFloat {
        if button == .zero {
            return (UIScreen.main.bounds.width - 4 * 12) / 4 * 2
        }
        return (UIScreen.main.bounds.width - 5 * 12) / 4
    }
}
