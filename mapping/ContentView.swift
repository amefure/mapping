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
    
    // 全ビューのデータの根源となるクラス
    @ObservedObject var allLocation = AllLocation()
    
    @ObservedObject var locationManager = LocationManager()
    
    // TabViewのセレクトタグ
    @State var selectedTag = 1
    
    // フィルタリング用Spot ListLocationView用
    @State var selectedSpot:Spot? = nil
    // フィルターのON/OFF  ListLocationView用
    @State var filter:Bool = false
    // Headerボタンが押されたか ListLocationView用
    @State var isClickFilter:Bool = false
    // Headerボタンが押されたか Map更新用
    @State var isClickUpdate:Bool = false
    
    
    init() {
        // TabView文字色
        UITabBar.appearance().unselectedItemTintColor = .white
        // TabView背景色
        UITabBar.appearance().backgroundColor = UIColor(displayP3Red:  0.4, green: 0.4, blue: 0.4, alpha: 1)
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        
        // 全てのViewでのヘッダー
        VStack (spacing: 0){
            
            HeaderView(selectedSpot:$selectedSpot, selectedTag: $selectedTag,filter: $filter,isClickFilter: $isClickFilter,isClickUpdate: $isClickUpdate).environmentObject(allLocation)
            
            TabView(selection: $selectedTag) {
                
                // 1.リスト表示View
                ListLocationView(selectedSpot: $selectedSpot,filter: $filter,isClick: $isClickFilter).tabItem({
                    Image(systemName: "list.bullet")
                    Text("リスト")}).tag(1).environmentObject(allLocation)
                // -----------------------------------------------------
                
                // 2.アノテーション配置View
                MappingView(isClick: $isClickUpdate).tabItem({
                    Image(systemName: "globe.asia.australia.fill")
                    Text("Map")}).tag(2).environmentObject(allLocation)
                // -----------------------------------------------------
                
                // 3.現在地を表示するView
                CurrentMapView(isClick: $isClickUpdate).tabItem({
                    Image(systemName: "figure.wave.circle")
                    Text("現在地")
                }).tag(3)
                // -----------------------------------------------------
                
                // 4.設定を操作するView
                SettingView().tabItem({
                    Image(systemName: "gearshape")
                    Text("設定")
                }).tag(4).environmentObject(allLocation)
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
