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
    @State var isAlertReward:Bool = false    // リワード広告視聴回数制限アラート
    
    @AppStorage("LastAcquisitionDate") var lastAcquisitionDate = "" // 参照：UserDefaults.standard.integer(forKey: "launchedCount")
    
    func nowTime() -> String{
            let df = DateFormatter()
            df.calendar = Calendar(identifier: .gregorian)
            df.locale = Locale(identifier: "ja_JP")
            df.timeZone = TimeZone(identifier: "Asia/Tokyo")
            df.dateStyle = .short
            df.timeStyle = .none
            return df.string(from: Date())
    }
    // シェアボタン
    func shareApp(shareText: String, shareLink: String) {
        let items = [shareText, URL(string: shareLink)!] as [Any]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
//            let deviceSize = UIScreen.main.bounds
            if let popPC = activityVC.popoverPresentationController {
                    popPC.sourceView = activityVC.view
                    popPC.barButtonItem = .none
//                 popPC.sourceRect = CGRect(x:deviceSize.size.width/2, y: deviceSize.size.height, width: 0, height: 0)
                popPC.sourceRect = activityVC.accessibilityFrame
            }
        }
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootVC = windowScene?.windows.first?.rootViewController
        rootVC?.present(activityVC, animated: true,completion: {})
    }
    
    var body: some View {
        NavigationView{
            List {
                
        
                Section(header: Text("設定"), footer: Text("※追加される容量は5個です。")) {
                    // 1:容量追加
                    Button(action: {
                        // 1日1回までしか視聴できないようにする
                        if lastAcquisitionDate != nowTime() {
                            reward.showReward()          //  広告配信
                            fileController.addLimitTxt() // 報酬獲得
                            lastAcquisitionDate = nowTime() // 最終視聴日を格納
                            
                        }else{
                            isAlertReward = true
                        }
                    }) {
                        HStack{
                            Image(systemName:"bag.badge.plus").frame(width: 30)
                            Text("広告を見て保存容量(※)を追加する")
                            Spacer()
                            Text("Spot:\(fileController.loadLimitTxt())")
                        }
                    }
                    .onAppear() {
                        reward.loadReward()
                    }
                    .disabled(!reward.rewardLoaded)
                    .alert(isPresented: $isAlertReward){
                        Alert(title:Text("お知らせ"),
                              message: Text("広告を視聴できるのは1日に1回までです"),
                              dismissButton: .default(Text("OK"),
                              action: {}))
                    }
                }
            
                // 1:容量追加
                
                Section {
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
                        shareApp(shareText: "mappingというアプリを使ってみてね♪", shareLink: "https://apps.apple.com/jp/app/mapping/id1639823172")
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
                }
                
            }.listStyle(GroupedListStyle()) // Listのスタイルを横に広げる
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }.navigationViewStyle(.stack) // NavigationView
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
