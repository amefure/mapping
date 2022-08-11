//
//  LocationModels.swift
//  mapping
//
//  Created by t&a on 2022/07/21.
//


import Foundation
import MapKit
import SwiftUI

//[{"address":"東京都千代田区千代田１−１","longitude":2,"id":"43358E09-F193-4183-99A2-9AC33195A5DC","memo":"良い場所","latitude":2,"spot":"施設","name":"東京スカイツリー"}]

struct Location:  Codable , Identifiable ,Equatable{
    
    var id = UUID()     // 識別子
    var address:String  // 住所
    var name:String     // 名称
    var memo:String     // メモ
    var spot:Spot       // スポットカテゴリ
    
    // アノテーション用-------------------
    var latitude: Double  // 緯度
    var longitude: Double // 経度
//    // 座標
    var coordinate:CLLocationCoordinate2D {
       CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    // アノテーション用-------------------
    
    
}



enum Spot:String,  Codable ,Identifiable ,CaseIterable{
    var id:String{self.rawValue}
    
    case house = "家"         // 人の家
    case restaurant = "飲食店" // 飲食店
    case shop = "ショップ"     // ショップ
    case facility = "施設"    // 施設
    case workplace  = "仕事場" // 仕事場
    case leisure = "レジャー"  // レジャー
    case nature = "自然"      // 自然
    case parking = "駐車場"   // 駐車場
    case others = "その他"    // その他
    
    var spotColor: Color{
        switch self {
        case .house:
            // Giant's Club : 赤
            return Color( red: 182/255, green: 95/255, blue: 77/255, opacity: 1)
        case .restaurant:
            // Metallic Orange : 橙
            return Color( red: 232/255, green: 106/255, blue: 15/255, opacity: 1)
        case .shop:
            // Crayola's Maize
            return Color( red: 244/255, green: 192/255, blue: 91/255, opacity: 1)
        case .facility:
            // : 茶色
            return Color( red:182/255, green: 134/255, blue: 77/255, opacity: 1)
        case .workplace:
            //  Independence : 青色
            return Color( red: 67/255, green: 76/255, blue: 109/255, opacity: 1)
        case .leisure:
            // : 紫
            return Color( red: 161/255, green: 77/255, blue: 182/255, opacity: 1)
        case .nature:
            // Slimy Green : 緑
            return Color( red: 79/255, green: 182/255, blue: 77/255, opacity: 1)
        case .parking:
            // Green Sheen : 水色
            return Color( red: 110/255, green: 168/255, blue: 158/255, opacity: 1)
        case .others:
            // : 薄ピンク
            return Color( red: 182/255, green: 77/255, blue: 134/255, opacity: 1)
        }
        
    }
    
    var accentColor: Color {
        switch self {
        case .house,.restaurant,.workplace,.facility, .leisure,.nature,.parking,.others : return .white
        case  .shop : return .black
        }
       }
    
    var spotImage:String{
        
        switch self {
        case .house:
            return "house.fill"
        case .restaurant:
            return "fork.knife"
        case .shop:
            return "tshirt"
        case .facility:
            return "building"
        case .workplace:
            return "display"
        case .leisure:
            return "person.3"
        case .nature:
            return "leaf"
        case .parking:
            return "car"
        case .others:
            return "mappin"
        }
        
        
    }
    
}

// -------------------------------------------------------------
// 全Location情報をデータとして持つクラス
class AllLocation:ObservableObject{
    
    @Published var allData:[Location] = []
    
    init(){
        // インスタンス化時にプロパティにデータを格納
        self.setAllData()
    }
    
    // 現在のLocation情報数をカウント
    func countAllData() -> Int{
        return self.allData.count
    }

    // 現在のJSONファイルの値をクラスのプロパティにセット
    func setAllData(){
        let f = FileController()
        self.allData = f.loadJson()
    }
    
    // 削除したいデータを共有しているクラスのプロパティからremove
    func removeLocation(_ item:Location){
        guard let index = allData.firstIndex(of: item) else { return }
        self.allData.remove(at: index)
    }
    
    // 編集されたデータを共有しているクラスのプロパティにupdate
    func updateLocation(_ item:Location,_ id:UUID){
        guard let index = allData.firstIndex(where: { $0.id == id }) else { return }
        self.allData[index] = item
    }
    
}
