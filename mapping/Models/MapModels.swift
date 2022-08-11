//
//  MapModels.swift
//  mapping
//
//  Created by t&a on 2022/07/21.
//

import MapKit

// 現在地を取得するためのクラス
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // CLLocationManagerをインスタンス化
    let manager = CLLocationManager()
    let geocoder = CLGeocoder()
    // 領域の更新をパブリッシュする
    @Published var region = MKCoordinateRegion()
    
    @Published var address:String? = ""
    
    override init() {
        super.init() // スーパクラスのイニシャライザを実行
        manager.delegate = self // 自身をデリゲートプロパティに設定
        manager.requestWhenInUseAuthorization() // 位置情報を利用許可をリクエスト
        manager.desiredAccuracy = kCLLocationAccuracyBest // 最高精度の位置情報を要求
        manager.distanceFilter = 3.0 // 更新距離(m)
        manager.startUpdatingLocation()
        self.reloadRegion()
        
    }
    
    func reloadRegion (){
        
        if let location = manager.location {
            
            geocoder.reverseGeocodeLocation( location, completionHandler: { ( placemarks, error ) in
                
                if let placemark = placemarks?.first {
                    //住所
                    let administrativeArea = placemark.administrativeArea == nil ? "" : placemark.administrativeArea!
                    let locality = placemark.locality == nil ? "" : placemark.locality!
                    let subLocality = placemark.subLocality == nil ? "" : placemark.subLocality!
                    let thoroughfare = placemark.thoroughfare == nil ? "" : placemark.thoroughfare!
                    let subThoroughfare = placemark.subThoroughfare == nil ? "" : placemark.subThoroughfare!
                    let placeName = !thoroughfare.contains( subLocality ) ? subLocality : thoroughfare
                    self.address = administrativeArea + locality + placeName + subThoroughfare
                }
            })
            
            let center = CLLocationCoordinate2D(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude)
            
            region = MKCoordinateRegion(
                center: center,
                latitudinalMeters: 1000.0,
                longitudinalMeters: 1000.0
            )
        }
    }
    
    
    // 位置情報が拒否された場合に初期表示位置を構築：東京スカイツリーの場所
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager){
        let guarded = manager.authorizationStatus.rawValue
        if guarded == 2 {
            let center = CLLocationCoordinate2D(
                latitude: 35.709152712026265,
                longitude: 139.80771829999996)
            
            region = MKCoordinateRegion(
                center: center,
                latitudinalMeters: 1000.0,
                longitudinalMeters: 1000.0
            )
        }
    }
    
    // ジオコーディング　住所 → 座標 InputViewの住所チェック
    func geocode(addressKey:String,completionHandler: @escaping (CLLocationCoordinate2D?) -> Void){
        
        geocoder.geocodeAddressString(addressKey) { (placemarks, error) in
            guard let unwrapPlacemark = placemarks else {
                // ジオコーディングできない文字列の場合
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
                return
            }
            // ジオコーディングできた文字列の場合
            let location  = unwrapPlacemark.first!.location!
            // 非同期処理で実行
            DispatchQueue.main.async {
                completionHandler(location.coordinate)
            }
        }
    }
}

// コピーしました用のメッセージバルーン
class MessageBalloon:ObservableObject{
    
    // opacityモディファイアの引数に使用
    @Published  var opacity:Double = 10.0
    // 表示/非表示を切り替える用
    @Published  var isPreview:Bool = false
    
    private var timer = Timer()
    
    // Double型にキャスト＆opacityモディファイア用の数値に割り算
    func castOpacity() -> Double{
        Double(self.opacity / 10)
    }
    
    // opacityを徐々に減らすことでアニメーションを実装
    func vanishMessage(){
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true){ _ in
            self.opacity = self.opacity - 1.0 // デクリメント
            
            if(self.opacity == 0.0){
                self.isPreview = false  // 非表示
                self.opacity = 10.0     // 初期値リセット
                self.timer.invalidate() // タイマーストップ
            }
        }
    }
    
}
