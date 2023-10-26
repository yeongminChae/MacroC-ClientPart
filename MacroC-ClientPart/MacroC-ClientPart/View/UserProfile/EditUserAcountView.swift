//
//  EditUserAcountView.swift
//  MacroC-ClientPart
//
//  Created by Kimdohyun on 2023/10/05.
//

import SwiftUI

struct EditUserAcountView: View {
    //MARK: -1.PROPERTY
    @EnvironmentObject var awsService: AwsService
    @State var showDeleteAlert: Bool = false
    
    //MARK: -2.BODY
    var body: some View {
        ZStack(alignment: .topLeading) {
            backgroundView().ignoresSafeArea()
            VStack(alignment: .leading) {
                //로그아웃
                Button {
                    KeychainItem.deleteUserIdentifierFromKeychain() //키체인에서 UserIdentifier 제거
                    awsService.isSignIn = false //로그인뷰로 돌아가기
                    UserDefaults.standard.set(false, forKey: "isSignIn")
                    try? KeychainItem(service: "com.DonsNote.MacroC-ClientPart", account: "tokenResponse").deleteItem()
                    print("EditUserAcountView.Log Out : delete User Identifier From Keychain")
                } label: {
                    Text("로그아웃")
                        .font(.custom13bold())
                        .padding(UIScreen.getWidth(20))
                        .shadow(color: .black.opacity(0.4),radius: UIScreen.getHeight(5))
                }
                //탈퇴
                Button {
                   showDeleteAlert = true
                } label: {
                    Text("탈퇴")
                        .foregroundStyle(Color(appRed))
                        .font(.custom13bold())
                        .padding(UIScreen.getWidth(20))
                        .shadow(color: .black.opacity(0.4),radius: UIScreen.getHeight(5))
                }
            }.padding(.top, UIScreen.getHeight(100))
                .alert(isPresented: $showDeleteAlert) {
                    Alert(title: Text(""), message: Text("Are you sure you want to delete your account?"), primaryButton: .destructive(Text("Delete"), action: {
                        awsService.deleteUser() // 서버에서 유저 지워버리기
                        awsService.isSignIn = false
                        UserDefaults.standard.set(false, forKey: "isSignIn")
                        try? KeychainItem(service: "com.DonsNote.MacroC-ClientPart", account: "tokenResponse").deleteItem()
                        print("탈퇴완료")
                        showDeleteAlert = true
                    }), secondaryButton: .cancel(Text("Cancle")))
                }
        }
    }
}

//#Preview {
//    EditUserAcountView(userAuth: aws)
//}
