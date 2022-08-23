//
//  RouteLocationView.swift
//  mapping
//
//  Created by t&a on 2022/08/17.
//

import SwiftUI

struct RouteLocationView: View {
    
    // RowLocationViewから引数として受け取ったLocation情報
    @State var item:Location
    // MapModels：
    @ObservedObject var locationManager = LocationManager()
    
    @State var expectedTravelTime:Double = -1  // 所要時間
    @State var distance: Double = 0            // 距離数
    
    func formatTime(_ time:Double) -> String{
        // 1分以下
        switch time {
        case -1 :
            return "経路を検索中..."
        case 0..<60 :
            return String(time) + "秒"
            
        case 0..<3600 :
            return String(format: "%.0f", time/60) + "分"

        default:
            let hour = Int(time/3600)
            let minutes = (time - Double(hour * 3600))/60
            return String(hour) + "時間" + String(format: "%.0f", minutes)  + "分"

        }
    }
    
    var body: some View {
        
        VStack{
            HStack{
                Spacer()
                Image(systemName:"clock")
                Spacer()
                Text("\(formatTime(expectedTravelTime))").frame(width: 200)
                Spacer()

            }
            HStack{
                Spacer()
                Image(systemName:"arrow.triangle.turn.up.right.circle")
                Spacer()
                Text(String(format: "%.1fkm", distance/1000)).frame(width: 200)
                Spacer()

            }
            UIMapView(region: locationManager.region, location: item,expectedTravelTime: $expectedTravelTime,distance: $distance)
        }
    }
}

struct RouteLocationView_Previews: PreviewProvider {
    static var previews: some View {
        RouteLocationView(item: Location(address: "東京都千代田区千代田１−１", name: "東京スカイツリー", memo: "良い場所", spot: .facility, latitude: 35.709152712026265, longitude: 139.80771829999996)).previewLayout(.sizeThatFits)
    }
}
