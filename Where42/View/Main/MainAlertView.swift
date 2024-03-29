//
//  HomeAlertView.swift
//  Where42
//
//  Created by 현동호 on 11/18/23.
//

import SwiftUI

struct MainAlertView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var mainViewModel: MainViewModel

    var body: some View {
        if mainViewModel.isNewGroupAlertPrsented {
            CustomAlert(
                title: "새 그룹 만들기",
                textFieldTitle: "그룹명 지정",
                inputText: $homeViewModel.inputText)
            {
                withAnimation {
                    homeViewModel.initNewGroup()
                    mainViewModel.isNewGroupAlertPrsented = false
                }
            } rightButtonAction: {
                withAnimation {
                    homeViewModel.confirmGroupName(
                        isNewGroupAlertPrsented: $mainViewModel.isNewGroupAlertPrsented,
                        isSelectViewPrsented: $mainViewModel.isSelectViewPrsented)
                }
            }
        }

        if mainViewModel.isEditGroupNameAlertPrsented {
            CustomAlert(
                title: "그룹 이름 수정",
                textFieldTitle: "그룹 이름을 입력해주세요",
                inputText: $homeViewModel.inputText)
            {
                withAnimation {
                    mainViewModel.isEditGroupNameAlertPrsented.toggle()
                }
            } rightButtonAction: {
                if await homeViewModel.editGroupName() {
                    withAnimation {
                        mainViewModel.isEditGroupNameAlertPrsented.toggle()
                    }
                }
            }
        }

        if mainViewModel.isDeleteGroupAlertPrsented {
            CustomAlert(
                title: "그룹 삭제",
                message: " 그룹 '\(homeViewModel.selectedGroup.groupName)' 을(를) 삭제하시겠습니까?",
                inputText: .constant(""))
            {
                withAnimation {
                    mainViewModel.isDeleteGroupAlertPrsented.toggle()
                }
            } rightButtonAction: {
                if await homeViewModel.deleteGroup() {
                    withAnimation {
                        mainViewModel.isDeleteGroupAlertPrsented.toggle()
                    }
                }
            }
        }
    }
}

#Preview {
    MainAlertView()
        .environmentObject(HomeViewModel())
        .environmentObject(MainViewModel())
}
