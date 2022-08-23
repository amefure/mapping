//
//  MappingView.swift
//  mapping
//
//  Created by t&a on 2022/07/22.
//

import SwiftUI
import MapKit



struct MappingView: View {
    // 共有されたAllLocationクラス
    @EnvironmentObject var allLocation : AllLocation
    @Environment(\.colorScheme) var colorScheme:ColorScheme
    // MapModels：
    @ObservedObject var locationManager = LocationManager()
    @Binding var isClick:Bool         // フィルターボタンを押されたかによってListLocationViewのNavigationLinkを操作
    
    let deviceWidth = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationView{
            Map(coordinateRegion: $locationManager.region,
                annotationItems: allLocation.allData,
                annotationContent: { point in MapAnnotation(coordinate: point.coordinate, content: {

                NavigationLink(destination: {
                    DetailLocationView(item: point)
                }, label: {
                    VStack{

                        Image(systemName: point.spot.spotImage)
                            .foregroundColor(point.spot.accentColor)
                            .frame(width: 30, height: 30)
                            .background(point.spot.spotColor)
                            .cornerRadius(30)
                        Text(point.name).foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                })
            })
            }
            ).navigationBarHidden(true) // Map
                .toolbar(){
                    ToolbarItem(placement: .bottomBar, content: {
                        // バナー広告
                        AdMobBannerView().frame(width: deviceWidth, height: 40)
                    })
                }
                .onChange(of: isClick, perform: { value in
                    locationManager.reloadRegion()
                })
        }.navigationViewStyle(.stack) // NavigationView
    }
}


struct MappingView_Previews: PreviewProvider {
    static var previews: some View {
        MappingView(isClick: Binding.constant(true))
    }
}
