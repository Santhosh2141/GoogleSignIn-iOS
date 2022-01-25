//
//  ChatUIView.swift
//  WeText
//
//  Created by Santhosh Srinivas on 15/12/21.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct FirebaseConstants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
    static let timestamp = "timestamp"
    static let phno = "phno"
    static let uid = "uid"
    static let messages = "messages"
    static let users = "users"
    static let recentMessages = "recent_messages"
}


class ChatLogViewModel: ObservableObject {

    @Published var chatText = ""
    @Published var errorMessage = ""

    @Published var chatMessages = [ChatMessage]()
    var firestoreListener: ListenerRegistration?
    var chatUser: ChatUser?
    
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        fetchMessages()
    }

    func fetchMessages(){
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        firestoreListener?.remove()
        chatMessages.removeAll()
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                        if let error = error{
                            self.errorMessage = "Failed to listen to Messages \(error)"
                            print(error)
                            return
                        }
                        querySnapshot?.documentChanges.forEach({ change in
                            if change.type == .added {
                                do {
                                    if let cm = try change.document.data(as: ChatMessage.self) {
                                        self.chatMessages.append(cm)
                                        print("Appending chatMessage in ChatLogView: \(Date())")
                                    }
                                } catch {
                                    print("Failed to decode message: \(error)")
                                }
                            }
                        })
                        DispatchQueue.main.async{
                        self.count += 1
                        }
                    }
            }
    func handleSend() {
        print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }

        guard let toId = chatUser?.uid else { return }

        let document = FirebaseManager.shared.firestore.collection("messages")
            .document(fromId)
            .collection(toId)
            .document()

        let msg = ChatMessage(id: nil, fromId: fromId, toId: toId, text: chatText, timestamp: Date())
        
        try? document.setData(from: msg) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            
            print("Successfully saved current user sending message")
            self.recentMessage()
            
            self.chatText = ""
            self.count += 1
        }

        let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()

        try? recipientMessageDocument.setData(from: msg) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }

            print("Recipient saved message as well")
            self.chatText = ""
        }
    }
    private func recentMessage(){
        guard let chatUser = chatUser else {
            return
        }

        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else { return }
        guard let toId = self.chatUser?.uid
        else { return }
        FirebaseManager.shared.firestore.collection(FirebaseConstants.recentMessages).document(uid).collection(FirebaseConstants.messages).document(toId)
        
        let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants
                            .recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .document(toId)
        
        let data = [
                    FirebaseConstants.timestamp: Timestamp(),
                    FirebaseConstants.text: self.chatText,
                    FirebaseConstants.fromId: uid,
                    FirebaseConstants.toId: toId,
                    FirebaseConstants.phno: chatUser.phno,
                ] as [String : Any]
        
        document.setData(data){ error in
                    if let error = error {
                        self.errorMessage = "Failed to save recent message: \(error)"
                        print("Failed to save recent message: \(error)")
                        return
                    }
                }
        
//        guard let currentUser = FirebaseManager.shared.currentUser
//        else { return }
//        let recipientRecentMessageDictionary = [
//            FirebaseConstants.timestamp: Timestamp(),
//            FirebaseConstants.text: self.chatText,
//            FirebaseConstants.fromId: uid,
//            FirebaseConstants.toId: toId,
//            FirebaseConstants.profileImageUrl: currentUser.profileImageUrl,
//            FirebaseConstants.username: currentUser.username
//        ] as [String : Any]
//
//        FirebaseManager.shared.firestore
//            .collection(FirebaseConstants.recentMessages)
//            .document(toId)
//            .collection(FirebaseConstants.messages)
//            .document(currentUser.uid)
//            .setData(recipientRecentMessageDictionary) { error in
//                if let error = error {
//                    print("Failed to save recipient recent message: \(error)")
//                    return
//                }
//            }
    }
    @Published var count = 0
    
}

struct ChatLogView: View {

//    let chatUser: ChatUser?
//
//    init(chatUser : ChatUser?){
//
//        self.chatUser = chatUser
//        self.vm = .init(chatUser: chatUser)
//    }
       //  @State var chatText = ""
    @ObservedObject var vm: ChatLogViewModel
//    @State var text = "good morning"
        var body: some View {
            VStack{
                Text("\(vm.chatUser?.phno ?? "") was last active x mins ago")
                ZStack{
                    messagesView
                    Text(vm.errorMessage)
                    
    //            ZStack {
    //                VStack(spacing: 0) {
    //                    Spacer()
    //                    chatBottomBar
    //                        .background(Color.white.ignoresSafeArea())
                }
                .navigationTitle("\(vm.chatUser?.phno ?? "")")
                    .navigationBarTitleDisplayMode(.inline)
                    .onDisappear{
                        vm.firestoreListener?.remove()
                    }
                    .navigationBarItems(trailing: Button{
                        vm.count += 1
                    }label: {
                        //Text("Count: \(vm.count)")
                    })
            }
        }

        private var messagesView: some View {
            ScrollView {
                ScrollViewReader{  scrollViewProxy in
                    VStack{
                        ForEach(vm.chatMessages){ message in
                          MessageView(message: message)
                        }
                        HStack{ Spacer() }
                        .id("Empty")
                    }
                    .onReceive(vm.$count){ _ in
                        withAnimation(.easeOut(duration: 0.5)){
                        scrollViewProxy.scrollTo("Empty", anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color(.init(white: 0.90, alpha: 1)))
            .safeAreaInset(edge: .bottom){
                chatBottomBar
                    .background(Color(.systemBackground) .ignoresSafeArea())
            }

        }

        private var chatBottomBar: some View {
            HStack(spacing: 16) {
                Image(systemName: "paperclip.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(.darkGray))
                ZStack {
                    DescriptionPlaceholder()
                    TextEditor(text: $vm.chatText)
                        .opacity(vm.chatText.isEmpty ? 0.5 : 1)
                }
                .frame(height: 40)

                Button {
                    vm.handleSend()
                } label: {
                    Text("Send")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(15)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
}
struct MessageView: View{
    let message: ChatMessage
    var body: some View{
        VStack{
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid{
                HStack {
                    Spacer()
                    HStack {
                        Text(message.text)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
                }
                
            } else {
                HStack {
                    // Spacer()
                    HStack {
                        Text(message.text)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    Spacer()
                }
            }
        }
        
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Enter you Text Here")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

struct ChatUIView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
