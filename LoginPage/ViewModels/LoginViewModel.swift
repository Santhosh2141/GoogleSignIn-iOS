//
//  LoginViewModel.swift
//  LoginPage
//
//  Created by Santhosh Srinivas on 17/12/21.
//

import SwiftUI
import FirebaseAuth
import Firebase

class LoginViewModel: ObservableObject {
    @Published var phno = ""
    @Published var code = ""
    @Published var errorMsg = ""
    @Published var error = false
    @Published var CODE = ""
    @Published var gotToVerify = false
    
    @Published var loading = false
    
    @AppStorage("log_Status") var status = false
    
    func getCountryCode() -> String {
        let regionCode = Locale.current.regionCode ?? ""
        
        return country[regionCode] ?? "" 
    }
    
    func sendCode(){
        
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        let number = "+\(getCountryCode())\(phno)"
        PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { (CODE ,err)  in
            if let error = err{
                self.errorMsg = error.localizedDescription
                print(error)
                withAnimation{ self.error.toggle()}
                return
            }
            self.CODE = CODE ?? ""
            self.gotToVerify = true
            
        }
    }
    
    func verifyCode(){
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.CODE, verificationCode: code)
        
        loading = true
        
        Auth.auth().signIn(with: credential) { (result, err) in
            self.loading = false
            if let error = err{
                self.errorMsg = error.localizedDescription
                withAnimation{ self.error.toggle()}
                return
            }
            withAnimation{self.status = true}
        }
    }
}
