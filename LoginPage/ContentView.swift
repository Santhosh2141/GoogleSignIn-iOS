//
//  ContentView.swift
//  LoginPage
//
//  Created by Santhosh Srinivas on 17/12/21.
//


import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

struct ContentView: View {
    
    @AppStorage("log_Status") var status = false
    var loginComplete = false
    
    var body: some View {
        ZStack{
            if status{
                
                HomeView()
                
            } else {
                NavigationView{
                    LoginView(loginComplete: {
                        
                    })
                }
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

