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
    case workplace  = "仕事場" // 仕事場
    case facility = "施設"    // 施設
    case leisure = "レジャー"  // レジャー
    case nature = "自然"      // 自然
    case parking = "駐車場"   // 駐車場
    case others = "その他"    // その他
    
    var spotColor: Color{
        switch self {
        case .house:
            // Lava : 赤
            return Color( red: 202/255, green: 25/255, blue: 28/255, opacity: 1)
        case .restaurant:
            // Metallic Orange : 橙
            return Color( red: 232/255, green: 106/255, blue: 15/255, opacity: 1)
        case .shop:
            // American Yellow
            return Color( red: 248/255, green: 181/255, blue: 3/255, opacity: 1)
        case .workplace:
            // Honolulu Blue : 青色
            return Color( red: 0/255, green: 93/255, blue: 185/255, opacity: 1)
        case .facility:
            // Silver Chalice : グレー
            return Color( red: 176/255, green: 173/255, blue: 163/255, opacity: 1)
        case .leisure:
            // Cadmium Violet : 紫
            return Color( red: 132/255, green: 65/255, blue: 171/255, opacity: 1)
        case .nature:
            // Slimy Green : 緑
            return Color( red: 61/255, green: 149/255, blue: 25/255, opacity: 1)
        case .parking:
            // Teal Blue : 水色
            return Color( red: 49/255, green: 137/255, blue: 150/255, opacity: 1)
        case .others:
            // Puce208, 143, 159)
            return Color( red: 208/255, green: 143/255, blue: 159/255, opacity: 1)
        }
        
    }
    
    var accentColor: Color {
        switch self {
        case .house,.restaurant,.workplace, .shop, .leisure,.nature,.parking,.others : return .white
        case  .facility : return .black
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
        case .workplace:
            return "display"
        case .facility:
            return "building"
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
