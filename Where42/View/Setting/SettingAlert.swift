//
//  SettingAlert.swift
//  Where42
//
//  Created by 현동호 on 1/20/24.
//

import SwiftUI

struct SettingAlert: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var settingViewModel: SettingViewModel
    @AppStorage("isLogin") var isLogin: Bool = false
    @AppStorage("token") var token = ""

    var body: some View {
        if settingViewModel.isLogoutAlertPresent {
            CustomAlert(title: "로그아웃", message: "로그아웃 하시겠습니까?", inputText: .constant("")) {
                withAnimation {
                    settingViewModel.isLogoutAlertPresent = false
                }
            } rightButtonAction: {
                withAnimation {
                    homeViewModel.isShowSettingSheet = false
                    settingViewModel.isLogoutAlertPresent = false
                    isLogin = false
                    token = ""
                    homeViewModel.isLogout = true
                }
            }
        }

        if settingViewModel.isStatusMessageAlertPresent {
            CustomAlert(title: "상태메세지 변경", textFieldTitle: "상태메세지를 입력해주세요", inputText: $settingViewModel.inputText) {
                withAnimation {
                    settingViewModel.isStatusMessageAlertPresent.toggle()
                    settingViewModel.inputText = ""
                }
            } rightButtonAction: {
                withAnimation {
                    settingViewModel.isStatusMessageAlertPresent.toggle()
                }
                await settingViewModel.UpdateComment()
                homeViewModel.myInfo.comment = settingViewModel.newStatusMessage
            }
        }

        if settingViewModel.isCustomLocationAlertPresent {
            CustomLocationView()
        }
    }
}

#Preview {
    SettingAlert()
}