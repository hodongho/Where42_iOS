//
//  HelpPage.swift
//  Where42
//
//  Created by 현동호 on 11/13/23.
//

import SwiftUI

struct HelpPage: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()

            HStack {
                Spacer()

                Text("어디있니?")
                    .font(.custom(Font.GmarketBold, size: 35))

                Spacer()
            }

            Spacer()

            Text("  안녕하세요! 42서울 친구 자리 찾기 서비스 '어디있니?'입니다.")
            Text("  '어디있니?'서비스에서는 원하는 카뎃의 자리를 검색해 볼 수 있고, 카뎃들을 친구로 등록하여 여러명의 자리를 한 번에 모아볼 수 있습니다.")
            Text("  더 자세한 사용방법은 아래 노션을 통해 확인 할 수 있습니다.")
            Text(.init("[Notion](https://www.notion.so/eff5de2f978a4164b52b68ad2ca2e05a)"))

            Spacer()

            Text("  우주여행을 하는 동안 동료들과 '어디있니?'를 통해 더 편히 학습하시길 바라며, 저희 '어디있니?' 서비스에 많은 관심 부탁드립니다.")

            Text("문의사항 : 42where@gmail.com")

            Spacer()
            Spacer()
        }
        .padding()
        .font(.custom(Font.GmarketMedium, size: 16))
        .lineSpacing(6)
    }
}

#Preview {
    HelpPage()
}