//
//  ListLocationView.swift
//  mapping
//
//  Created by t&a on 2022/07/23.
//

import SwiftUI

struct ListLocationView: View {
    // 共有されたAllLocationクラス
    @EnvironmentObject var allLocation : AllLocation
    // JSONファイル操作クラス
    var fileController = FileController()
    
    var body: some View {
        
        NavigationView{
                List(allLocation.allData.reversed()) { item in
                   
                    RowLocationView(item: item).environmentObject(allLocation)
                        // スワイプアクションを追加
                        .swipeActions(edge: .trailing, allowsFullSwipe: false){
                            
                            // 削除ボタン
                            Button(role: .destructive, action: {
                                // 押下時にアニメーション
                                withAnimation(.linear(duration: 0.3)){
                                    allLocation.removeLocation(item)
                                    fileController.updateJson(allLocation.allData)
                                    allLocation.setAllData()
                                }
                            }, label: {
                                Image(systemName: "trash")
                            })
                        }
            }.navigationTitle("リスト")
                .listStyle(GroupedListStyle()) // Listのスタイルを横に広げる
                .navigationBarHidden(true) // 非表示
                .font(.system(size: 15))
        }  // NavigationView
    }
}

struct ListLocationView_Previews: PreviewProvider {
    static var previews: some View {
        ListLocationView()
    }
}
