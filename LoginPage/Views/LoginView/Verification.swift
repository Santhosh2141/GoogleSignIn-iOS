//
//  Verification.swift
//  LoginPage
//
//  Created by Santhosh Srinivas on 17/12/21.
//

import SwiftUI

struct Verification: View {
    @ObservedObject var lm : LoginViewModel
    @Environment(\.presentationMode) var present
    
    var body: some View {
        
        ZStack{
            VStack{
                VStack{
                    HStack{
                        Button(action: { present.wrappedValue.dismiss()}){
                            Image(systemName: "arrow.left")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                        Spacer()
                        Text("Verify Phone NUmber")
                            .font(.title2)
                        Spacer()
                        
                        if lm.loading{ProgressView()}
                    }
                .padding()
                    Text("Veification Code sent to \(lm.phno)")
                        .foregroundColor(.gray)
                        .padding(.bottom)
                    Spacer()
                    HStack(spacing: 15){
                        ForEach(0..<6, id: \.self){ val in
                            CodeView(code: getCodeIndex(index: val))
                        }
                    }
                    .padding()
                    Spacer()
                    HStack(spacing: 6){
                        Text(" DIDNT GET ANY OTP?? RESEND AGAIN")
                        
                        Text(" SEND OTP VIA CALL")
                    }
                        Button{
                            lm.verifyCode()
                        } label: {
                            Text("Verify and Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical)
                                .frame(width: UIScreen.main.bounds.width - 30)
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                    }
                .frame(height: UIScreen.main.bounds.height / 1.8)
                .cornerRadius(20)
                
                
                CustomNumPad(value: $lm.code, isVerify: true)

                Spacer()
            }
            .background(Color("bg" ).ignoresSafeArea(.all,edges: .bottom))
            
            if lm.error{
                AlertView(msg: lm.errorMsg, show: $lm.error)
            }

        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    func getCodeIndex (index: Int) -> String{
        if lm.code.count > index {
            let start = lm.code.startIndex
            let current = lm.code.index(start, offsetBy: index)
            return String(lm.code[current])
        }
        return ""
    }
}


struct CodeView : View {
    var code: String
    var body: some View{
        VStack(spacing: 10){
            Text(code)
                .fontWeight(.bold)
                .font(.title2)
                .frame(height: 45)
            
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(height: 4)
        }
    }
}
