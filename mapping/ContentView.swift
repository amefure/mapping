//
//  ContentView.swift
//  mapping
//
//  Created by t&a on 2022/07/21.
//

import SwiftUI
import MapKit

// ContentView > HeaderView > InputLocationView
// ContentView > ListLocationView > RowLocationView > DetailLocationView > InputLocationView
// ContentView > MappingView
// ContentView > CurrentMapView

 // #E46977

struct ContentView: View {
    // TabViewのセレクトタグ
    @State  var selectedTag = 1
    
    // 全ビューのデータの根源となるクラス
    @ObservedObject var allLocation = AllLocation()
    
    
    init() {
        // TabView文字色
        UITabBar.appearance().unselectedItemTintColor = .white
        // TabView背景色
        UITabBar.appearance().backgroundColor = UIColor(displayP3Red:  0.4, green: 0.4, blue: 0.4, alpha: 1)
    }
    
 
    
    var body: some View {
        
        // 全てのViewでのヘッダー
        VStack (spacing: 0){
            HeaderView().environmentObject(allLocation)
        TabView(selection: $selectedTag) {
            
            // 1.リスト表示View
            ListLocationView().tabItem({
                Image(systemName: "list.bullet")
                Text("リスト")}).tag(1).environmentObject(allLocation)
            // -----------------------------------------------------
            
            // 2.アノテーション配置View
            MappingView().tabItem({
                Image(systemName: "globe.asia.australia.fill")
                Text("Map")}).tag(2).environmentObject(allLocation)
            // -----------------------------------------------------
            
            // 3.現在地を表示するView
            CurrentMapView().tabItem({
                Image(systemName: "figure.wave.circle")
                Text("現在地")
            }).tag(3)
            // -----------------------------------------------------
        } // TabView
            .accentColor(Color("ThemaColor"))

        }
        
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
