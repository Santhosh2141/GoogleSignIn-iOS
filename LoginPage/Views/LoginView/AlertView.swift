//
//  AlertView.swift
//  LoginPage
//
//  Created by Santhosh Srinivas on 17/12/21.
//

import SwiftUI

struct AlertView: View {
    var msg: String
    @Binding var show: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 15, content: {
            Text("Message")
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(msg)
                .foregroundColor(.black)
            Button(action: {
                show.toggle()
            }, label: { 
                Text("Close")
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 100)
                    .foregroundColor(.white)
                    .background(Color(.blue))
                    .cornerRadius(15)
            })
                .frame(alignment: .center)
        })
            .padding()
            .padding(.horizontal, 25)
            .background(Color(.init(gray: 0.95, alpha: 2)))
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        
                
    }
}

