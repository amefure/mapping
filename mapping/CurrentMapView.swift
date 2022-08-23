//
//  CurrentMapView.swift
//  mapping
//
//  Created by t&a on 2022/07/21.
//

import SwiftUI
import MapKit

struct CurrentMapView: View {
    
    // インスタンス-----------------------------------------
    // MapModels：
    @ObservedObject var locationManager = LocationManager()
    // メッセージバルーンクラス：
    @ObservedObject var messageBalloon = MessageBalloon()
    
    // プロパティ-----------------------------------------
    // 現在地表示用真偽値
    @State var isPreview:Bool = false
    @Binding var isClick:Bool         // フィルターボタンを押されたかによってListLocationViewのNavigationLinkを操作
    // デバイスの横幅と高さ
    let deviceWidth = UIScreen.main.bounds.width
    let deviceHeight = UIScreen.main.bounds.height
    
    @State var annotationItem:[Location] = []
    
    // 現在地のアノテーションを格納処理
    func setAnnotation(){
        self.annotationItem = [Location(address: "", name: "現在地", memo: "", spot: .others, latitude: locationManager.region.center.latitude, longitude: locationManager.region.center.longitude)]
    }
    
    var body: some View {
        NavigationView{
            VStack {
                ZStack{
                    // セクション1-----------------------------------------
                    Map(coordinateRegion: $locationManager.region,
                        annotationItems: annotationItem,
                        annotationContent: { point in MapAnnotation(coordinate: point.coordinate, content: {
                                VStack{
                                    Circle().fill(Color.white).frame(width: 25, height: 25)
                                    Circle().fill(Color("ThemaColor")).frame(width: 18, height: 18).opacity(0.8).offset(x: 0, y: -30)
                                }
                        })}
                    )
                    // セクション1-----------------------------------------
                    
                    // セクション2---------------------------------------
                    Button(action: {
                        isPreview.toggle()
                    }, label: {
                        if(isPreview){
                            Image(systemName: "mappin.slash")
                                .font(.system(size:40))
                        }else{
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size:40))
                        }
                    }).frame(width: 70 , height: 70)
                    
                        .foregroundColor(.white)
                        .background(Color("ThemaColor"))
                        .cornerRadius(70)
                        .position(x: deviceWidth/2, y: deviceHeight/1.6)
                    // セクション2-----------------------------------------
                    // セクション3-----------------------------------------
                    Group{
                        if(isPreview){
                            HStack {
                                Spacer()
                                Text((locationManager.address != "" ?  locationManager.address : "位置情報をONにしてください" ) ?? "取得できないエリアです…")
                                    .font(.system(size: 20))
                                    .textSelection(.enabled)
                                
                                ZStack {
                                    if (messageBalloon.isPreview){
                                        Text("コピーしました")
                                            .font(.system(size: 9))
                                            .padding(4)
                                            .background(Color(red: 0.3, green: 0.3 ,blue: 0.3))
                                            .foregroundColor(.white)
                                            .opacity(messageBalloon.castOpacity())
                                            .cornerRadius(5)
                                            .offset(x: -5, y: -24)
                                    }
                                    Button(action: {
                                        UIPasteboard.general.string = locationManager.address
                                        messageBalloon.isPreview = true
                                        messageBalloon.vanishMessage()
                                    }, label: {
                                        Image(systemName: "doc.on.doc")
                                            .frame(width: 70)
                                    }).disabled(messageBalloon.isPreview)
                                } // ZStack
                            } // HStack
                            
                        }else{ //  if(isPreview)
                            Text("現在地は…？")
                                .font(.system(size: 20))
                                .textSelection(.enabled)
                        }
                        
                        
                    }.padding(.top,20)
                        .frame(width: deviceWidth,height: 70)
                        .foregroundColor(.white)
                        .background(Color( red: 0.4, green: 0.4, blue: 0.4, opacity: 1))
                        .position(x: deviceWidth/2, y: 25)
                    
                    // セクション3-----------------------------------------
                }
            } // VStack
            .navigationBarHidden(true) // Map
            .toolbar(){
                ToolbarItem(placement: .bottomBar, content: {
                    // バナー広告
                    AdMobBannerView().frame(width: deviceWidth, height: 40)
                })
            }
            .onChange(of: isClick, perform: { value in
                // Headerボタンクリック時の処理
                locationManager.reloadRegion()
                setAnnotation()
            })
            .onAppear(){
                // 画面表示時にアノテーションを表示
                setAnnotation()
            }
        } // NavigationView
        .navigationViewStyle(.stack)
    }
}

struct CurrentMapView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentMapView(isClick: Binding.constant(true))
    }
}
