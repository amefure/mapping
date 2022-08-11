//
//  SettingView.swift
//  mapping
//
//  Created by t&a on 2022/08/04.
//

import SwiftUI
import UIKit

struct SettingView: View {
    // JSONファイル操作クラス
    var fileController = FileController()
    // AdMob reward広告
    @ObservedObject var reward = Reward()
    // 共有されたAllLocationクラス
    @EnvironmentObject var allLocation : AllLocation
    // モード取得
    @Environment(\.colorScheme) var colorScheme : ColorScheme
    
    
    @State var isModal:Bool = false    // InputLocationView表示/非表示
    @State var isAlert:Bool = false    // 全データ削除ボタンの確認アラート
    
    // シェアボタン
    func shareApp(shareText: String, shareImage: Image, shareLink: String) {
        let items = [shareText, shareImage, URL(string: shareLink)!] as [Any]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootVC = windowScene?.windows.first?.rootViewController
        rootVC?.present(activityVC, animated: true,completion: {})
    }
    
    var body: some View {
        NavigationView{
            List{
                
                // 1:容量追加
                Button(action: {
                    reward.showReward()
                    fileController.addLimitTxt()
                    
                }) {
                    HStack{
                        Image(systemName:"bag.badge.plus").frame(width: 30)
                        Text("広告を見て保存容量を追加する")
                        Spacer()
                        Text("Spot:\(fileController.loadLimitTxt())")
                    }
                }
                .onAppear() {
                    reward.loadReward()
                }
                .disabled(!reward.rewardLoaded)
                // 1:容量追加
                
                
                // 2:利用規約とプライバシーポリシー
                Link(destination:URL.init(string: "https://ame.hp.peraichi.com/")!, label: {
                    HStack{
                        Image(systemName:"note.text").frame(width: 30)
                        Text("利用規約とプライバシーポリシー")
                        Image(systemName:"link").font(.caption)
                    }
                })
                // 2:プライバシーポリシー
                
                
                // 3:シェアボタン
                Button(action: {
                    shareApp(shareText: "mappingというアプリを使ってみてね♪", shareImage: Image(systemName: "globe.asia.australia"), shareLink: "https://tech.amefure.com/")
                }) {
                    HStack{
                        Image(systemName:"star.bubble").frame(width: 30)
                        Text("シェアする")
                    }
                }
                // 3:シェアボタン
                
                
                
                // 4:全データ削除ボタン-----------------------------
                Button(action: {
                    isAlert = true
                    
                }, label: {
                    HStack {
                        Image(systemName: "trash.fill").frame(width: 30)
                        Text("全てのデータを削除する")
                    }.foregroundColor(.accentColor)
                    
                })
                .alert(isPresented: $isAlert){
                    Alert(title:Text("確認"),
                          message: Text("「全てのデータ」がリセットされます。\nよろしいですか？"),
                          primaryButton: .destructive(Text("削除する"),
                                                      action: {
                        fileController.clearFile()
                        allLocation.setAllData()
                    }), secondaryButton: .cancel(Text("キャンセル")))
                }
                // 4:全データ削除ボタン-----------------------------
                
            }.listStyle(GroupedListStyle()) // Listのスタイルを横に広げる
                .navigationTitle(Text("設定"))
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
