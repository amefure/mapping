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
    
    let deviceWidth = UIScreen.main.bounds.width
    let deviceHeight = UIScreen.main.bounds.height
    
    @Binding var selectedSpot:Spot? // フィルタリングされるSpot
    @Binding var filter:Bool        // フィルターのON/OFF
    @Binding var isClick:Bool       // Headerボタンを押したかどうか  Linkの実行ON/OFF
    
    var body: some View {
        
        NavigationView{
            
            ZStack {
                
                Image("icon").resizable().aspectRatio(contentMode: .fill)
                    .frame(width: deviceWidth/6, height: deviceHeight/6)
                    .position(x: deviceWidth/2, y: deviceHeight/2.5)
                    .opacity(0.2)
                
                // 非表示状態にするNavigationLink
                NavigationLink("フィルタリング", destination: SpotPickerView(selectedSpot: $selectedSpot), isActive: $isClick).hidden()
                
                
                VStack{
                    
                    List(allLocation.allData.reversed().filter(filter ? { $0.spot == selectedSpot } : { $0.name != "" })) { item in
                        
                        RowLocationView(item: item).environmentObject(allLocation)
                            .listRowBackground(Color.clear)
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
                    // バナー広告
                    AdMobBannerView().frame(width: deviceWidth, height: 40)
                }
            } //  ZStack
        }  // NavigationView
    }
}

struct ListLocationView_Previews: PreviewProvider {
    static var previews: some View {
        ListLocationView(selectedSpot: Binding.constant(.house),filter: Binding.constant(false),isClick: Binding.constant(false))
    }
}
