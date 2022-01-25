//
//  LoginView.swift
//  LoginPage
//
//  Created by Santhosh Srinivas on 17/12/21.
//

import SwiftUI

struct LoginView: View {
    
    let loginComplete: () -> ()

//    @State var loginMode = true
//    @State var email = ""
//    @State var pass = ""
//    @State var uName = ""
//    @State var showImgPicker = false
    @State var phno = ""
    
    @StateObject var lm = LoginViewModel()
    @State var isSmall = UIScreen.main.bounds.height < 750
    
    var body: some View {
        ZStack{
            VStack{
                VStack{
                    Text("Continue with phone")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding()
                    Text("You'll recieve a six digit otp to verify")
                        .font(isSmall ? .none : .title2)
                        .foregroundColor(.gray)
                        .padding()
                    HStack{
                        VStack(alignment: .leading, spacing: 2){
                            Text("Enter your number")
                                .font(.title)
                                .foregroundColor(.gray)
                            Text("+ \(lm.getCountryCode()) \(lm.phno) ")
                                .font(.title)
                        }
                        Spacer(minLength: 0)
                        
                        NavigationLink(destination: Verification(lm : lm), isActive: $lm.gotToVerify){
    //
                            Text("")
                                .hidden()
                        }
                        Button(action: lm.sendCode, label: {
                            Text("Continue")
                               .foregroundColor(.white)
                               .padding(.vertical, 18)
                               .padding(.horizontal, 38)
                               .background(Color.blue)
                               .cornerRadius(15)
                        })
                        .disabled(lm.phno == "" ? true: false)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    
                }
                .frame(height: UIScreen.main.bounds.height / 1.8)
                
                CustomNumPad(value: $lm.phno, isVerify: false)
                
            }
            .background(Color("bg").ignoresSafeArea(.all, edges: .bottom))
            
            if lm.error{
                AlertView(msg: lm.errorMsg, show: $lm.error)
            }
        }
    }
    
    
    @State private var statusLogin = ""

    private func storeUserInformation() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["phno": self.phno, "uid": uid]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    self.statusLogin = "\(err)"
                    return
                }

                print("Success")
                self.loginComplete()
            }
    }
}
