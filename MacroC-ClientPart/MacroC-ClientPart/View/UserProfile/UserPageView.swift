//
//  UserPageView.swift
//  MacroC-ClientPart
//
//  Created by Kimjaekyeong on 2023/10/16.
//

import SwiftUI
import PhotosUI

struct UserPageView: View {
    
    //MARK: -1.PROPERTY
    @EnvironmentObject var awsService: AwsService
    @ObservedObject var viewModel = UserPageViewModel()
    
    //MARK: -2.BODY
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: UIScreen.getWidth(5)) {
                    if viewModel.croppedImage != nil { pickedImage }
                    else { artistPageImage }
                    userPageTitle
                    Spacer()
                }
            }.blur(radius: viewModel.isEditName || viewModel.isEditInfo ? 15 : 0)
            if viewModel.isEditName || viewModel.isEditInfo {
                Color.black.opacity(0.1)
                    .onTapGesture {
            //                        viewModel.isEditSocial = false
                        viewModel.isEditName = false
                        viewModel.isEditInfo = false
                    }
            }
            //수정시트 모달
            //            if viewModel.isEditSocial {
            //                editSocialSheet
            //            }
            if viewModel.isEditName {
                editNameSheet
            }
            if viewModel.isEditInfo {
                editInfoSheet
            }
            //저장완료 알림 모달
            //            if viewModel.socialSaveOKModal {
            //                PopOverText(text: "저장되었습니다")
            //            }
            if viewModel.nameSaveOKModal {
                PopOverText(text: "저장되었습니다")
            }
            if viewModel.infoSaveOKModal {
                PopOverText(text: "저장되었습니다")
            }
        }
        .background(backgroundView())
        .ignoresSafeArea()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { firstToolbarItem.opacity(viewModel.isEditName || viewModel.isEditInfo ? 0 : 1) }
            ToolbarItem(placement: .topBarTrailing) { secondToolbarItem.opacity(viewModel.isEditName || viewModel.isEditInfo ? 0 : 1) }
        }
//        .photosPicker(isPresented: $viewModel.popImagePicker, selection: $viewModel.selectedItem)
        .cropImagePicker(show: $viewModel.popImagePicker, croppedImage: $viewModel.croppedImage, isLoding: $viewModel.isLoading)
        
        .onChange(of: viewModel.selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    viewModel.selectedPhotoData = data
                }
            }
        }
        .onChange(of: viewModel.selectedPhotoData) { newValue in
            if let data = newValue, let uiImage = UIImage(data: data) {
                viewModel.copppedImageData = data
                viewModel.croppedImage = uiImage
                viewModel.popImagePicker = false
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationTitle("")
    }
}



//MARK: -3.PREVIEW
#Preview {
    NavigationView {
        UserPageView()
    }
}

//MARK: -4.EXTENSION
extension UserPageView {
    var artistPageImage: some View {
        AsyncImage(url: URL(string: awsService.user.avatarUrl)) { image in
            image.resizable().aspectRatio(contentMode: .fit)
        } placeholder: {
            ProgressView()
        }
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
        .mask(LinearGradient(gradient: Gradient(colors: [Color.black,Color.black,Color.black, Color.clear]), startPoint: .top, endPoint: .bottom))
        //            .overlay (
        //                HStack(spacing: UIScreen.getWidth(10)){
        //                    Button { } label: { linkButton(name: YouTubeLogo) }
        //
        //                    Button { } label: { linkButton(name: InstagramLogo) }
        //
        //                    Button { } label: { linkButton(name: SoundCloudLogo) }
        //
        //                    Button {viewModel.isEditSocial = true} label: {
        //                        if viewModel.isEditMode == true {
        //                            Image(systemName: "pencil.circle.fill")
        //                                .font(.custom20semibold())
        //                        } else { }
        //                    }
        //                }
        //                    .frame(height: UIScreen.getHeight(25))
        //                    .padding(.init(top: 0, leading: 0, bottom: UIScreen.getWidth(20), trailing: UIScreen.getWidth(15)))
        //                ,alignment: .bottomTrailing )
        .overlay(alignment: .bottom) {
            if viewModel.isEditMode {
                Button{
                    viewModel.popImagePicker = true
                } label: {
                    //TODO: 사진첩 접근해서 사진 받는 거 구현
                    Image(systemName: "camera.circle.fill")
                        .font(.custom40bold())
                        .shadow(color: .black.opacity(0.7),radius: UIScreen.getWidth(5))
                }
            }
        }
    }
    
        var pickedImage: some View {
            Image(uiImage: viewModel.croppedImage!)
                .resizable()
                .scaledToFit()
                .mask(LinearGradient(gradient: Gradient(colors: [Color.black,Color.black,Color.black, Color.clear]), startPoint: .top, endPoint: .bottom))
            //            .overlay (
            //                HStack(spacing: UIScreen.getWidth(10)){
            //                    Button { } label: { linkButton(name: YouTubeLogo) }
            //
            //                    Button { } label: { linkButton(name: InstagramLogo) }
            //
            //                    Button { } label: { linkButton(name: SoundCloudLogo) }
            //                }
            //                    .frame(height: UIScreen.getHeight(25))
            //                    .padding(.init(top: 0, leading: 0, bottom: UIScreen.getWidth(20), trailing: UIScreen.getWidth(15)))
            //                ,alignment: .bottomTrailing )
                .overlay(alignment: .bottom) {
                    if viewModel.isEditMode {
                        PhotosPicker(
                            //TODO: 사진첩 접근해서 사진 받는 거 구현
                            selection: $viewModel.selectedItem,
                            matching: .images,
                            photoLibrary: .shared()) {
                                Image(systemName: "camera.circle.fill")
                                    .font(.custom40bold())
                                    .shadow(color: .black.opacity(0.7),radius: UIScreen.getWidth(5))
                           }
                    }
                }
        }
    
    var userPageTitle: some View {
        return VStack{
            ZStack {
                Text(awsService.user.username)
                    .font(.custom40black())
                if viewModel.isEditMode == true {
                    HStack {
                        Spacer()
                        Button {
                            viewModel.isEditName = true
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.custom20semibold())
                                .shadow(color: .black.opacity(0.7),radius: UIScreen.getWidth(5))
                                .padding(.horizontal)
                        }
                    }
                }
            }
            ZStack {
                Text(viewModel.EditUserInfo)
                    .font(.custom13heavy())
                if viewModel.isEditMode == true {
                    HStack {
                        Spacer()
                        Button { viewModel.isEditInfo = true } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.custom20semibold())
                                .shadow(color: .black.opacity(0.7),radius: UIScreen.getWidth(5))
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }.padding(.bottom, UIScreen.getHeight(20))
        
    }
    
    var firstToolbarItem: some View {
        if viewModel.isEditMode {
            return AnyView(Button {
                viewModel.isEditMode = false
                // 선택한 사진들 취소하는 함수들
                viewModel.selectedItem = nil
                viewModel.selectedPhotoData = nil
                viewModel.croppedImage = nil
                
                //                viewModel.isEditSocial = false
                viewModel.isEditName = false
                viewModel.isEditInfo = false
            } label: {
                toolbarButtonLabel(buttonLabel: "Cancle").shadow(color: .black.opacity(0.5),radius: UIScreen.getWidth(8))
            })
        } else {
            return AnyView(EmptyView())
        }
    }
    
    var secondToolbarItem: some View {
        if viewModel.isEditMode {
            return AnyView(Button{
                feedback.notificationOccurred(.success)
                                viewModel.isEditMode = false
                                //                viewModel.isEditSocial = false
                                viewModel.isEditName = false
                                viewModel.isEditInfo = false
                //TODO: 세이브하는 거 구현

                awsService.patchcroppedImage = viewModel.croppedImage
                awsService.patchUserProfile()
            } label: {
                toolbarButtonLabel(buttonLabel: "Save").shadow(color: .black.opacity(0.5),radius: UIScreen.getWidth(8))
            })
        } else {
            return AnyView(Button{
                viewModel.isEditMode = true
            } label: {
                toolbarButtonLabel(buttonLabel: "Edit").shadow(color: .black.opacity(0.5),radius: UIScreen.getWidth(8))
            })
        }
    }
    
    //    var editSocialSheet: some View {
    //        VStack(alignment: .leading, spacing: UIScreen.getWidth(10)) {
    //            HStack {
    //                Image(YouTubeLogo)
    //                    .resizable()
    //                    .scaledToFit()
    //                    .frame(width: UIScreen.getWidth(20))
    //                Text("Youtube")
    //                    .font(.custom14semibold())
    //            }
    //            TextField("", text: $viewModel.userArtist.youtube)
    //                .font(.custom12semibold())
    //                .padding(UIScreen.getWidth(12))
    //                .background(.ultraThinMaterial)
    //                .cornerRadius(6)
    //            HStack {
    //                Image(InstagramLogo)
    //                    .resizable()
    //                    .scaledToFit()
    //                    .frame(width: UIScreen.getWidth(20))
    //                Text("Instagram")
    //                    .font(.custom14semibold())
    //            }
    //            TextField("", text: $viewModel.userArtist.instagram)
    //                .font(.custom12semibold())
    //                .padding(UIScreen.getWidth(12))
    //                .background(.ultraThinMaterial)
    //                .cornerRadius(6)
    //            HStack {
    //                Image(SoundCloudLogo)
    //                    .resizable()
    //                    .scaledToFit()
    //                    .frame(width: UIScreen.getWidth(20))
    //                Text("SoundCloud")
    //                    .font(.custom14semibold())
    //            }
    //            TextField("", text: $viewModel.userArtist.soundcloud)
    //                .font(.custom12semibold())
    //                .padding(UIScreen.getWidth(12))
    //                .background(.ultraThinMaterial)
    //                .cornerRadius(6)
    //            //SocialEditSheet Button
    //            Button {
    //                //TODO: 서버에 올리는 함수 구현하기
    //                //TODO: 밖에 빈백 누르면 수정된 값 초기화하는 함수 구현하기
    //                feedback.notificationOccurred(.success)
    //                withAnimation(.smooth(duration: 0.5)) {
    //                    viewModel.socialSaveOKModal = true // TODO: 서버에서 석세스 받으면 되도록 옵셔널로 바꾸기
    //                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
    //                        viewModel.socialSaveOKModal = false
    //                        viewModel.isEditSocial = false
    //                    }
    //                }
    //            } label: {
    //                HStack {
    //                    Spacer()
    //                    Text("Save")
    //                    Spacer()
    //                }
    //                .font(.custom14semibold())
    //                .padding(UIScreen.getWidth(14))
    //                .background(LinearGradient(colors: [.appSky ,.appIndigo1, .appIndigo2], startPoint: .topLeading, endPoint: .bottomTrailing))
    //                .cornerRadius(6)
    //            }
    //            .padding(.top, UIScreen.getWidth(26))
    //        }
    //        .padding(.init(top: UIScreen.getWidth(10), leading: UIScreen.getWidth(10), bottom: UIScreen.getWidth(10), trailing: UIScreen.getWidth(10)))
    //    }
    
    var editNameSheet: some View {
        VStack(alignment: .leading, spacing: UIScreen.getWidth(10)) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.getWidth(20))
                    .padding(.leading, UIScreen.getWidth(3))
                Text("User Name").font(.custom14semibold())
            }
            TextField("", text: $viewModel.EditUsername)
                .font(.custom10semibold())
                .padding(UIScreen.getWidth(12))
                .background(.ultraThinMaterial)
                .cornerRadius(6)
            //editNameSheet Button
            Button {
                //TODO: 서버에 올리는 함수 구현하기
                awsService.user.username = viewModel.EditUsername
                //TODO: 밖에 빈백 누르면 수정된 값 초기화하는 함수 구현하기
                feedback.notificationOccurred(.success)
                withAnimation(.smooth(duration: 0.5)) {
                    viewModel.nameSaveOKModal = true // TODO: 서버에서 석세스 받으면 되도록 옵셔널로 바꾸기
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        viewModel.nameSaveOKModal = false
                        viewModel.isEditName = false
                    }
                }
            } label: {
                HStack {
                    Spacer()
                    Text("Save")
                    Spacer()
                }
                .font(.custom14semibold())
                .padding(UIScreen.getWidth(14))
                .background(LinearGradient(colors: [.appSky ,.appIndigo1, .appIndigo2], startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(6)
            }
        }
        .padding(.horizontal, UIScreen.getWidth(10))
        .presentationDetents([.height(UIScreen.getHeight(150))])
        .presentationDragIndicator(.visible)
    }
    
    var editInfoSheet: some View {
        VStack(alignment: .leading, spacing: UIScreen.getWidth(10)) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.getWidth(20))
                    .padding(.leading, UIScreen.getWidth(3))
                Text("User Info").font(.custom14semibold())
            }
            TextField("", text: $viewModel.EditUserInfo)
                .font(.custom10semibold())
                .padding(UIScreen.getWidth(12))
                .background(.ultraThinMaterial)
                .cornerRadius(6)
            //editInfoSheet Button
            Button {
                //TODO: 서버에 올리는 함수 구현하기
                //UserInfo 없애야하나;;;;
                //TODO: 밖에 빈백 누르면 수정된 값 초기화하는 함수 구현하기
                feedback.notificationOccurred(.success)
                withAnimation(.smooth(duration: 0.5)) {
                    viewModel.infoSaveOKModal = true // TODO: 서버에서 석세스 받으면 되도록 옵셔널로 바꾸기
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        viewModel.infoSaveOKModal = false
                        viewModel.isEditInfo = false
                    }
                }
            } label: {
                HStack {
                    Spacer()
                    Text("Save")
                    Spacer()
                }
                .font(.custom14semibold())
                .padding(UIScreen.getWidth(14))
                .background(LinearGradient(colors: [.appSky ,.appIndigo1, .appIndigo2], startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(6)
            }
        }
        .padding(.horizontal, UIScreen.getWidth(10))
        .presentationDetents([.height(UIScreen.getHeight(150))])
        .presentationDragIndicator(.visible)
    }
}
