//
//  RowLocationView.swift
//  mapping
//
//  Created by t&a on 2022/07/23.
//

import SwiftUI

struct RowLocationView: View {
    
    // 共有されたAllLocationクラス
    @EnvironmentObject var allLocation : AllLocation
    
    // ListLocationViewから引数として受け取ったLocation情報
    @State var item:Location
    
    @Binding var selectedSpot:Spot? // フィルタリングされるSpot
    @Binding var filter:Bool        // フィルターのON/OFF
    @State var demoTag:Int = 0 // 存在しないタグをdetailに渡す mapViewからListへ飛ばす用
    
    var body: some View {

        NavigationLink(destination: {DetailLocationView(item: item,selectedSpot: $selectedSpot,filter: $filter,selectedTag:$demoTag).environmentObject(allLocation)}, label: {
            VStack(alignment:.leading) {
                
                Text(item.name).font(.system(size: 20))
                HStack{
                    Image(systemName: item.spot.spotImage).foregroundColor(item.spot.spotColor).frame(width:25)
                    Text(item.memo)
                }.font(.system(size: 15))
                
            }.textSelection(.enabled)
                .lineLimit(1)
                
            
        })
    }
}

struct RowLocationView_Previews: PreviewProvider {
    static var previews: some View {
        RowLocationView(item: Location(address: "東京都千代田区千代田１−１", name: "東京スカイツリー", memo: "良い場所", spot: .facility, latitude: 35.709152712026265, longitude: 139.80771829999996),selectedSpot: Binding.constant(.house),filter: Binding.constant(false)).previewLayout(.sizeThatFits)
    }
}
