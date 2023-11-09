//
//  PaymentView.swift
//  CrossGate
//
//  Created by Gui Castro on 26/06/2023.
//

import Combine
import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import SDWebImageSwiftUI

struct Payment: Identifiable {
    var id: String { uid }
    let uid, name, profileImageUrl, timestamp: String
    let users: [String]
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.timestamp = data["timestamp"] as? String ?? ""
        self.users = data["users"] as? [String] ?? [""]
    }
}

class PaymentViewModel: ObservableObject {
   
    

}
struct UnderlineView: ViewModifier {
  let spacing: CGFloat
  let height: CGFloat
  let color: Color

  func body(content: Content) -> some View {
    VStack(spacing: spacing) {
      content
      Rectangle()
        .frame(height: height)
        .foregroundColor(color)
    }
  }
}
extension View {
  func underlined(spacing: CGFloat = 6,
                  height: CGFloat = 1,
                  color: Color = .gray) -> some View {
    self.modifier(UnderlineView(spacing: spacing,
                                height: height,
                                color: color))
  }
}


struct PaymentView: View {
    @Binding var currentPage: String
    @State var billValue = ""
    @State var description = ""
    @State var GroupSelected = "Select Group"
    @State var GroupSelectedId = ""
    @State var curGroup: GroupOfPeople?
    @State var paymentList = [[Int]]()
    @State var test = ""
    @State private var showingAlert = false
    
   // @ObservedObject private var vm = PaymentViewModel()
    @State var currentGroup: GroupOfPeople?
    @ObservedObject private var vm2 = GroupsViewModel()
    let formatter: NumberFormatter = {
           let formatter = NumberFormatter()
           formatter.numberStyle = .decimal
           return formatter
       }()
    
    func buttonClick (paymentList: [Any], paymentValue: Float){
        
        let uid = vm2.currentUser?.id ?? ""
        let paymentID = UUID().uuidString
        let paymentData = ["uid": paymentID, "users": paymentList, "description": description , "timestamp": Timestamp()] as [String : Any]

        //
        Firestore.firestore().collection("payments")
            .document(currentGroup?.id ??          "").collection(uid).document("Lent").collection(paymentID).document(paymentID).setData(paymentData as [String : Any])
        
        let paymentDataBorrowed = ["uid": paymentID, "amount": paymentValue, "description": description , "timestamp": Timestamp()] as [String : Any]
        
        for user in curGroup?.users ?? [] {
            //print("test")
            if (user != uid){
                print(user)
                Firestore.firestore().collection("payments")
                    .document(currentGroup?.id ??          "").collection(user).document("Borrowed").collection(paymentID).document(paymentID).setData(paymentDataBorrowed as [String : Any]) { err in
                        if let err = err {
                            print(err)
                            //self.errorMessage = "\(err)"
                            return
                        }
                        
                    }
            }
        }
        
        
        
    }
    func beforeButtonClick (){
        let uid = vm2.currentUser?.id ?? ""
        let numberOfUsersInGroup = Float((curGroup?.users ?? []).count)
        
        let valueEachOwes = (Float(Int(billValue) ?? 0) / numberOfUsersInGroup)
        //        print ( Int(billValue) ?? 0)
        //        print ( 55 / 2)
        let roundedValue = (valueEachOwes * 100).rounded() / 100
        var listUsersAndPayments: [[String: Any]] = []

        for user in curGroup?.users ?? [] {
            if (user != uid){
                let userData: [String: Any] = [
                    "user": user,
                    "payment": roundedValue
                ]
                listUsersAndPayments.append(userData)}
        }
       // print(listUsersAndPayments)
        buttonClick(paymentList: listUsersAndPayments, paymentValue : roundedValue)
        
    }

    
    var bill: some View {
        VStack{
            Spacer()
            
            HStack{
               Image (systemName: "dollarsign")
                    .resizable()
                    .frame(width: 20.0, height: 32.0)
                VStack{
                    TextField("0.00", text: $billValue)
                        .underlined()
                        .frame(width: 250, height: nil)
                        .padding(.all, 5)
                        .font(Font.system(size: 40, design: .default))
                        .multilineTextAlignment(.leading)
                        .keyboardType(.numberPad)
                        .onReceive(Just(billValue)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.billValue = filtered
                            }
                        }
                    
                }
                .frame(maxWidth: 100, alignment: .leading)
                .lineLimit(nil)
                Spacer()
            }
            .padding(.leading, 80.0)
            HStack{
                
                Image (systemName: "note.text")
                    .resizable()
                    .frame(width: 30.0, height: 32.0)
                VStack{
                    
                    TextField("Enter a description", text: $description)
                        .underlined()
                        .frame(width: 250, height: nil)
                        .padding(.all, 5)
                    
                        .font(Font.system(size: 30, design: .default))
                        .multilineTextAlignment(.leading)
                    
                    
                    
                }
                
                .frame(maxWidth: 100, alignment: .leading)
                
                .lineLimit(nil)
                
                Spacer()
                
            }
            .padding(.leading, 75.0)
            //Text(currentGroup?.name ?? "")
            //List()
            Menu(GroupSelected) {
                ForEach(vm2.groups){group in
                    Button{
                        //shouldNavigateToGroupInfoView.toggle()
                
                        self.currentGroup = group
                        GroupSelected = group.name
                        GroupSelectedId = group.id
                        curGroup = group
                    } label: {
                        Text(group.name).foregroundColor(Color(.label))
                        
                    }
                }
            }
            
            
            Button{
                //buttonClick()
                if ((curGroup?.id) == nil){
                    showingAlert = true
                }
                if (billValue == ""){
                    showingAlert = true
                }
                if (description == ""){
                    showingAlert = true
                }
                else{
                    beforeButtonClick()}
                
                
            } label : {
                 Text("ADD")
                     .frame(minWidth: 0, maxWidth: .infinity)
                     .font(.system(size: 18))
                     .padding()
                     .foregroundColor(.white)
                     .overlay(
                         RoundedRectangle(cornerRadius: 25)
                             .stroke(Color.white, lineWidth: 2)
                 )
             }
             .background(Color.blue) // If you have this
             .cornerRadius(25)
             .padding(.vertical, 30)
             .padding(.horizontal, 40.0)
            
            Spacer()
                
        }
        .alert("Please Fill All The Information", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        
        
        
    }
    
        }
    
    
    var body: some View {
        HStack{
           
            VStack{
                Text("Add Expense")
                Spacer()
                HStack{
                    
                    bill}
                
                TabView(currentPage: $currentPage)
            }
            
        }
        
    }
    
    
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentView(currentPage: .constant("0"))
    }
}
