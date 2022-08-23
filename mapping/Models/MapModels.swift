//
//  MapModels.swift
//  mapping
//
//  Created by t&a on 2022/07/21.
//

import MapKit
import SwiftUI

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

// 経路表示用ビュー　UIKitビューをSwiftUIに変換して表示
// ------------------------------------------

class LocationPin: NSObject, MKAnnotation {
    
    var title: String?
    var latitude: Double  // 緯度
    var longitude: Double // 経度
    // 座標
    var coordinate:CLLocationCoordinate2D {
       CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(title:String, latitude: Double ,longitude: Double) {
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct UIMapView: UIViewRepresentable {
    let Manager = MapManager()
    var region:MKCoordinateRegion // 現在地
    var location:Location         // 対象ロケーション
    @Binding var expectedTravelTime:Double // 所要時間　秒単位
    @Binding var distance: Double         // 距離数 m単位


    func makeUIView(context: Self.Context) -> MKMapView {

        let mapView = Manager.mapViewObj

        
        let basePin1 = LocationPin(title: "現在地",latitude:region.center.latitude, longitude: region.center.longitude)
        let basePin2 = LocationPin(title: location.name, latitude: location.latitude, longitude: location.longitude)
        
        
        mapView.addAnnotation(basePin1)
        mapView.addAnnotation(basePin2)
        

        let basePlaceMark1 = MKPlacemark(coordinate: basePin1.coordinate)
        let basePlaceMark2 = MKPlacemark(coordinate: basePin2.coordinate)

        let directionRequest = MKDirections.Request() // リクエストインスタンス
        directionRequest.source = MKMapItem(placemark: basePlaceMark1) // 地点1登録
        directionRequest.destination = MKMapItem(placemark: basePlaceMark2) // 地点2登録
        directionRequest.transportType = MKDirectionsTransportType.automobile // 移動方法登録

        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            // オプショナルバインディングで取り出す
            guard let directionResonse = response else {
                if let error = error {
                    print("発生したエラー内容：\(error.localizedDescription)")
                }
                return // nilなら処理を終了
            }
            // ルートを取得
            let route = directionResonse.routes[0]
            // 所用時間と距離を格納
            context.coordinator.expectedTravelTime = route.expectedTravelTime
            context.coordinator.distance = route.distance
            // ビューにオーバーレイオブジェクトを追加
            mapView.addOverlay(route.polyline, level: .aboveRoads)
            // 2地点間がちょうど表示される縮尺を取得
            let rect = route.polyline.boundingMapRect
    
            var rectRegion = MKCoordinateRegion(rect) // 縮尺を少しズームアウト
            rectRegion.span.latitudeDelta = rectRegion.span.latitudeDelta * 1.2
            rectRegion.span.longitudeDelta = rectRegion.span.longitudeDelta * 1.2
            mapView.setRegion(rectRegion, animated: true)

        }

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Self.Context) {
        uiView.delegate = Manager
    }
    
    func makeCoordinator() -> Coordinator {
           Coordinator(self,expectedTravelTime: $expectedTravelTime,distance: $distance)
       }
    

} // class

extension UIMapView{
    class Coordinator: NSObject {
        
        var control: UIMapView
        
        @Binding var expectedTravelTime:Double // 所要時間　秒単位
        @Binding var distance:Double // 距離数  m単位
        
        init(_ control: UIMapView,expectedTravelTime:Binding<Double>,distance:Binding<Double>){
           self.control = control
            // Binding型はアンダースコア(_)をつける
            _expectedTravelTime  = expectedTravelTime
            _distance = distance
       }
        
    }
}

class MapManager:NSObject, MKMapViewDelegate{
    var mapViewObj = MKMapView()
    
    var expectedTravelTime:Double = 0   // 所用時間
    var distance: Double = 0      // 距離数
    
    override init() {
        super.init() // スーパクラスのイニシャライザを実行
        mapViewObj.delegate = self // 自身をデリゲートプロパティに設定
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
          let renderer = MKPolylineRenderer(overlay: overlay)
          renderer.strokeColor = UIColor.orange
          renderer.lineWidth = 3.0
          return renderer
    }
    
    //  アノテーション変更
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "annotation"
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                annotationView.annotation = annotation
                return annotationView
            } else {
                let annotationView = MKMarkerAnnotationView(
                    annotation: annotation,
                    reuseIdentifier: identifier
                )
                annotationView.markerTintColor = UIColor(named: "ThemaColor") // 色変更
                return annotationView
            }
        }

}

