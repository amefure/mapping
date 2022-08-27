//
//  DetailLocationView.swift
//  mapping
//
//  Created by t&a on 2022/07/27.
//

import SwiftUI

// ContentView > HeaderView > InputLocationView
// ContentView > ListLocationView > RowLocationView > DetailLocationView > InputLocationView
// ContentView > MappingView
// ContentView > CurrentMapView

struct DetailLocationView: View {
    
    @Environment(\.colorScheme) var colorScheme:ColorScheme
    // NavigationViewを閉じるメソッド
    @Environment(\.dismiss) var dismiss
    // 共有されたAllLocationクラス
    @EnvironmentObject var allLocation : AllLocation
    
    // メッセージバルーンクラス：
    @ObservedObject var messageBalloon = MessageBalloon()
    
    // RowLocationViewから引数として受け取ったLocation情報
    @State var item:Location
    
    // InputLocationView表示/非表示
    @State var isModal:Bool = false
    
    @Binding var selectedSpot:Spot? // フィルタリングされるSpot
    @Binding var filter:Bool        // フィルターのON/OFF
    @Binding var selectedTag:Int    // Content > mapView > Detail のみリストに画面遷移させるため
    
    var fileController = FileController()
    
    // モーダルから更新されたデータをビューに反映させる(Environmentではモーダルからの変化を受け取れない?)
    func updateItem(_ data:Location){
        item = data // Inputのデータを格納すれば上(Row < List)に変化が伝わる
    }
    
    let deviceWidth = UIScreen.main.bounds.width
    let deviceHeight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack{
            
            // SpotImage背景用
            Image(systemName: item.spot.spotImage)
                .opacity(colorScheme == .dark ? 0.3 : 0.1)
                .foregroundColor(item.spot.spotColor)
                .font(.system(size: deviceHeight/2))
                .position(x: deviceWidth/1.1, y: deviceHeight/4)
            
            VStack (alignment: .leading){
                
                    HStack{
                        Button(action: {
                            // カテゴリボタン押下でカテゴリフィルタリング実行
                            selectedSpot = item.spot
                            filter = true
                            dismiss() // Navigationを戻す
                            // MapViewからの遷移に限りListへ強制遷移 遅延処理でdismissの実行を待つ
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                if selectedTag != 0 {
                                    selectedTag = 1
                                }
                            }
                            
                            
                        }, label: {
                            Text(item.spot.rawValue).padding(5)
                                    .background(item.spot.spotColor)
                                    .cornerRadius(3)
                                    .foregroundColor(item.spot.accentColor)
                        })
                            
                
                            Spacer()
                        
                        NavigationLink(destination: RouteLocationView(item: item), label: {
                            HStack(alignment: .center, spacing: 0){
                            Text("Route")
                            Image(systemName:"arrow.triangle.turn.up.right.circle")
                        }}).padding(5)
                            .background(item.spot.spotColor)
                            .cornerRadius(3)
                            .foregroundColor(item.spot.accentColor)
                        
                    }.font(.system(size: 15)) // HStack
                
                VStack(alignment: .leading){
                    Text(item.name)
                    // 下線を表示
                    Rectangle()
                        .foregroundColor(item.spot.spotColor)
                        .frame(height: 2)
                        .offset(x: 0, y: -5)
                } // VStack(alignment: .leading)
                
                Spacer() // 名称-----------------------------
                
                Group{
                    HStack {
                        Image(systemName: "text.justify.left").font(.system(size: 15))
                        Text("MEMO")
                        Spacer()
                    }.foregroundColor(item.spot.spotColor)
                    
                    HStack{
                        Text(item.memo).padding()
                        Spacer()
                    }.overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                        .padding(.bottom)
                } //Group
                
                Spacer() // MEMO-----------------------------
                
                Group{
                        HStack {
                            HStack (alignment:.bottom){
                                Image(systemName:"mappin").foregroundColor(item.spot.spotColor)
                                Text("：\(item.address)").font(.system(size: 15))
                            }
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
                                    UIPasteboard.general.string = item.address
                                    messageBalloon.isPreview = true
                                    messageBalloon.vanishMessage()
                                }, label: {
                                    Image(systemName: "doc.on.doc")
                                        .frame(width: 70)
                                        .foregroundColor(.gray)
                                }).disabled(messageBalloon.isPreview)
                            } // ZStack
                        } // HStack
                } //Group
            } // VStack
        }.font(.system(size: 20)) // ZStack
            .textSelection(.enabled)
            .padding()
            .navigationBarBackButtonHidden(true)
            .toolbar(){
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button(action:{
                        dismiss()
                    },label: {
                        Image(systemName:"arrow.backward")
                    }).foregroundColor(item.spot.spotColor)
                })
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    
                    Button(action: {
                        isModal = true
                    }, label: {
                        Image(systemName:"square.and.pencil")
                    }).foregroundColor(item.spot.spotColor)
                    
                    
                })
                ToolbarItem(placement: .bottomBar, content: {
                    // バナー広告
                    AdMobBannerView().frame(width: deviceWidth, height: 40)
                })
            }
            .sheet(isPresented: $isModal, content: {
                InputLocationView(isModal: $isModal,item:item,parentUpdateItemFunction: updateItem).environmentObject(allLocation)
            })
        
    }
}

struct DetailLocationView_Previews: PreviewProvider {
    static var previews: some View {
        DetailLocationView(item: Location(address: "東京都千代田区千代田１−１", name: "東京スカイツリー", memo: "良い場所", spot: .facility, latitude: 35.709152712026265, longitude: 139.80771829999996),selectedSpot: Binding.constant(.house),filter: Binding.constant(false),selectedTag: Binding.constant(1)).previewLayout(.sizeThatFits)
    }
}
