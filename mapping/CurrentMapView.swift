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
    @State var tapAddress:String = ""
    
    var body: some View {
        NavigationView{
            VStack {
                ZStack{
                    // セクション1-----------------------------------------
                    UIMapAddressGetView(tapAddress:$tapAddress)
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
                                Text((locationManager.address != "" ?  (tapAddress != "" ? tapAddress : locationManager.address) : "位置情報をONにしてください" ) ?? "取得できないエリアです…")
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
                                        UIPasteboard.general.string = (tapAddress != "" ? tapAddress : locationManager.address)
                                        messageBalloon.isPreview = true
                                        messageBalloon.vanishMessage()
                                    }, label: {
                                        Image(systemName: "doc.on.doc")
                                            .frame(width: 70)
                                    }).disabled(messageBalloon.isPreview)
                                } // ZStack
                            } // HStack
                            
                        }else{ //  if(isPreview)
                            
                            Text((tapAddress != "" ? "選択した住所は...?" : "現在地は...?"))
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
            .onChange(of: isClick, perform: { _ in
                // Headerボタンクリック時の処理
                locationManager.reloadRegion()
                tapAddress = "" // タップアドレスを空にする
            })
        } // NavigationView
        .navigationViewStyle(.stack)
    }
}

struct CurrentMapView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentMapView(isClick: Binding.constant(true))
    }
}
