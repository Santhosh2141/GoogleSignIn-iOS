//
//  SearchBar.swift
//  WeText
//
//  Created by Santhosh Srinivas on 17/12/21.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @State var isEditing = false
    var body: some View {
        HStack{
            TextField("Enter a Name to search", text: $text)
                .padding(15)
                .padding(.horizontal,25)
                .background(Color(.systemGray6))
                .foregroundColor(.black)
                .cornerRadius(8)
                .overlay(
                    HStack{
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.blue)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(15)
                    if isEditing{
                        Button{
                            self.text = ""
                            
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.blue)
                                .padding(.trailing, 8)
                        }
                    }
                }
                ).onTapGesture {
                    self.isEditing = true
                }
            if isEditing{
                Button{
                    self.isEditing = false
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                } label: {
                    Text("Cancel")
                }
            }
        }
    }
}


