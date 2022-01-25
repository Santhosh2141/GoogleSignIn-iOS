//
//  HomeView.swift
//  LoginPage
//
//  Created by Santhosh Srinivas on 18/12/21.
//
////
//import SwiftUI
//import Firebase
//import FirebaseAuth
//
//struct HomeView: View {
//
//    @AppStorage("log_Status") var status = false
//
//    var body: some View {
//        VStack(spacing: 15){
//
//            Text("Logged In Successfully")
//                .font(.title)
//                .fontWeight(.heavy)
//            Button{
//                try? Auth.auth().signOut()
//                withAnimation { status = false }
//            } label: {
//                Text("Log OUT")
//                    .fontWeight(.heavy)
//            }
//        }
//    }
//}

//
//  MainMsgView.swift
//  WeText
//
//  Created by Santhosh Srinivas on 14/12/21.
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase

class HomeViewModel: ObservableObject {

    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut = false

    init() {
            DispatchQueue.main.async {
                self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
            
            }
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    @Published var recentMessageArray = [RecentMessage]()
    private var firestoreListener: ListenerRegistration?
    
    func fetchRecentMessages(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else { return }
        firestoreListener?.remove()
        self.recentMessageArray.removeAll()
        
        
        firestoreListener =  FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener{ querySnapshot, error in
                if let error = error{
                    self.errorMessage = "Failed to listen to recent message \(error)"
                    print(error)
                    return
                }
                querySnapshot?.documentChanges.forEach({
                    change in
                        let docId = change.document.documentID
                        if let index = self.recentMessageArray.firstIndex(where: {rm in
                            return rm.id == docId
                        })
                        {
                            self.recentMessageArray.remove(at: index)
                        }
                    do{
                        if let rm = try change.document.data(as: RecentMessage.self){
                            self.recentMessageArray.insert(rm, at: 0)
                        }
                    } catch{
                        print(error)
                    }
                    //                        self.recentMessageArray.insert(.init(documentId: docId, data: change.document.data()), at: 0)
//                        self.recentMessageArray.append()
                })
            }
    }
    func fetchCurrentUser() {

        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }

        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }

            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return

            }
            self.chatUser = .init(data: data)
        }
    }
    
    @Published var isCurrentlyLoggedOut = false
    
    func handleSignOut(){
        isUserCurrentlyLoggedOut.toggle()
                 try? FirebaseManager.shared.auth.signOut()
    }

}

struct HomeView: View {
    
    @ObservedObject var vm = HomeViewModel()
    @State var shouldShowLogOutOptions = false
    @State var shouldNavigateToChatLogView = false
    private var chatLogViewModel1 = ChatLogViewModel(chatUser: nil)

    var body: some View {
        NavigationView{
            VStack{
                customNavBar
                ScrollView{
                    VStack{
                        ForEach (vm.recentMessageArray){ recentMessage in
                            Button {
                                let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
                                
                                self.chatUser = .init(data:[FirebaseConstants.phno : recentMessage.phno, FirebaseConstants.uid : uid])
                                self.chatLogViewModel1.chatUser = self.chatUser
                                self.chatLogViewModel1.fetchMessages()
                                self.shouldNavigateToChatLogView.toggle()
                        } label: {
                            HStack{
                                VStack(alignment: .leading){
                                    Text(recentMessage.phno)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(.label))
                                    Text(recentMessage.text)
                                        .foregroundColor(Color(.lightGray))
                                        .multilineTextAlignment(.leading)
                                        
                                }
                                Spacer()
                                Text(recentMessage.timeAgo)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                        Divider()
                            .padding(.vertical,8)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom,50)
            }
                NavigationLink("", isActive: $shouldNavigateToChatLogView){
                    
                    ChatLogView(vm: chatLogViewModel1)
                    
                }
            }
            .overlay(newMessageButton,alignment: .bottom)
            .navigationBarHidden(true)
            
        }
    }
    private var customNavBar: some View{
        VStack{
            Text("    WeText")
                .font(.system(size: 32, weight: .heavy))
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 16){
                VStack(alignment: .leading, spacing: 2){
                    
                    //Text("\(vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? "")")
                     Text(vm.chatUser?.phno ?? "")
                        .font(.system(size: 28, weight: .semibold))
                    HStack{
                        Circle()
                            .foregroundColor(.green)
                            .frame(width: 14, height: 12, alignment: .leading)
                        Text("Online")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                Button {
                    shouldShowLogOutOptions.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(.label))
                    }
            }.padding()
            .actionSheet(isPresented: $shouldShowLogOutOptions) {
                .init(title: Text("Settings"), message: Text("Do you want to switch Accounts?"), buttons: [
                    .destructive(Text("Sign Out"), action: {
                        print("signing out")
                        vm.handleSignOut()
                    }),
                        .cancel()
                ])
            }
            .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
                LoginView(loginComplete: {
                    self.vm.isUserCurrentlyLoggedOut = false
                    self.vm.fetchCurrentUser()
                    self.vm.fetchRecentMessages()
                }
            )}
        }
    }
    
    @State var newMsgScreen = false
    
    private var newMessageButton: some View{
        Button {
                newMsgScreen.toggle()
            } label: {
                HStack {
                    Spacer()
                    Text("+ New Message")
                        .font(.system(size: 16, weight: .bold))
                        Spacer()
                    }
                .foregroundColor(.white)
                .padding(.vertical)
                    .background(Color.blue)
                    .cornerRadius(24)
                    .padding(.horizontal)
                    .shadow(radius: 16)
            }
            .fullScreenCover(isPresented: $newMsgScreen, onDismiss: nil){
                NewMessageView(selectNewUser: { user in
                    print(user.phno)
                    self.shouldNavigateToChatLogView.toggle()
                    self.chatUser = user
                    self.chatLogViewModel1.chatUser = user
                    self.chatLogViewModel1.fetchMessages()
            })
        }
        
    }
        @State var chatUser: ChatUser?
}


struct MainMsgView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

