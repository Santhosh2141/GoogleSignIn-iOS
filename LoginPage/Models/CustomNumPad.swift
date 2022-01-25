//
//  CustomNumPad.swift
//  LoginPage
//
//  Created by Santhosh Srinivas on 17/12/21.
//

import SwiftUI

struct CustomNumPad: View {
    
    @Binding var value: String
    var isVerify: Bool
    
    var rows = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "delete.backward"]
    var body: some View {
        GeometryReader{ reader in
            VStack{
                LazyVGrid(columns:Array(repeating: GridItem(.flexible(),spacing: 20), count: 3), spacing: 15){
                    ForEach(rows, id: \.self){row in
                        Button(action: {ButtonAction(value: row)}){
                            ZStack{
                                if row == "delete.backward"{
                                    Image(systemName: "delete.backward")
                                        .font(.title2)
                                        .foregroundColor(.black)
                                } else{
                                    Text(row)
                                        .font(.title)
                                        .foregroundColor(.black)
                                        .fontWeight(.bold)
                                }
                            }.frame(maxWidth: .infinity)
                                .frame(height: getHeight(height: reader.frame(in: .global).height))
                                .background(.white)
                                .cornerRadius(10)
                        }
                        .disabled(row == "" ? true: false)
                    }
                }
            }
        }
        .padding()
    }
    func getHeight(height: CGFloat) -> CGFloat {
        let actualHeight = height - 40
        return (actualHeight / 4) > 0 ? (actualHeight / 4) : 0
    }
    func getWidth(frame: CGRect) -> CGFloat {
        let width = frame.width
        let actulWidth = width - 40
        return actulWidth / 3
    }
    func ButtonAction(value: String){
        if value == "delete.backward" && self.value != "" {
            self.value.removeLast()
        }
        if value != "delete.backward" {
            if isVerify{
                if self.value.count < 6{
                    self.value.append(value)
                }
            } else{
                self.value.append(value)
            }
        }
    }
}
