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
        } // NavigationView
    }
}


struct MappingView_Previews: PreviewProvider {
    static var previews: some View {
        MappingView()
    }
}
