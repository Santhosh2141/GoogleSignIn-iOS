//
//  NewMessageView.swift
//  WeText
//
//  Created by Santhosh Srinivas on 15/12/21.
//

import SwiftUI


class CreateNewMessageViewModel: ObservableObject {

    @Published var users = [ChatUser]()
    @Published var errorMessage = ""

    init() {
        fetchAllUsers()
    }

    private func fetchAllUsers() {
        FirebaseManager.shared.firestore.collection("users")
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch users: \(error)"
                    print("Failed to fetch users: \(error)")
                    return
                }

                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let user = ChatUser(data: data)
                    if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                        self.users.append(.init(data: data))
                    }

                })
            }
    }
}

struct NewMessageView: View {
    
    let selectNewUser: (ChatUser) -> ()
    @State var text = ""
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = CreateNewMessageViewModel()
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack{
                    SearchBar(text: $text)
                    Text(vm.errorMessage)

                    ForEach(vm.users.filter({
                        "\($0)".contains(text) || text.isEmpty
                    })) { user in
                        Button {
                            presentationMode.wrappedValue.dismiss()
                            selectNewUser(user)
                        } label: {
                            HStack(spacing: 16) {
                                Text(user.phno)
                                    .foregroundColor(Color(.label))
                                Spacer()
                            }.padding(.horizontal)
                        }
                        Divider()
                            .padding(.vertical, 8)
                        }
                    }
                }.navigationTitle("New Message")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
        }
    }
}

struct NewMessageView_Previews: PreviewProvider {
    static var previews: some View {
//        NewMessageView()
        HomeView()
    }
}
