//
//  UIMapModels.swift
//  mapping
//
//  Created by t&a on 2022/08/26.
//

import SwiftUI
import MapKit

// Swift UIでは実装できない地図機能を実装する
// 1:UIMapRouteView：経路表示用ビュー
// 2:UIMapAddressGetView：長押し位置の住所を取得
// MARK: -

// アノテーション用クラス
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

// MARK: -
struct UIMapRouteView: UIViewRepresentable {
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
                    // 経路取得に失敗フラグを立てる
                    context.coordinator.distance = -1
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

extension UIMapRouteView{
    class Coordinator: NSObject {
        
        var control: UIMapRouteView
        
        @Binding var expectedTravelTime:Double // 所要時間　秒単位
        @Binding var distance:Double // 距離数  m単位
        
        init(_ control: UIMapRouteView,expectedTravelTime:Binding<Double>,distance:Binding<Double>){
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
// MARK: - タップした住所を取得


struct UIMapAddressGetView: UIViewRepresentable {
    
    
    @State var mapView = MKMapView()
    @State var tapped:Bool = false   // タップしたかどうか
    @Binding var tapAddress:String   // タップされた住所を格納
    @ObservedObject var locationManager = LocationManager()
    
    func makeUIView(context: Self.Context) -> MKMapView {
        
        let region = locationManager.region
        
        let gesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.longTapped(_:))
        )
        mapView.addGestureRecognizer(gesture)
        mapView.region = region
        
        let currentPin = LocationPin(title: "",latitude:region.center.latitude, longitude: region.center.longitude)
        mapView.addAnnotation(currentPin)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Self.Context) {
        // ビュー更新時にタップかつリセット(CurrentMapVieewのHeaderボタンを押下)されていれば
        if tapped == true && tapAddress == ""{
            // アノテーションリセット
            if !mapView.annotations.isEmpty{
                mapView.removeAnnotation(mapView.annotations[0])
            }
            // 現在地をセット
            let region = locationManager.region
            let currentPin = LocationPin(title: "",latitude:region.center.latitude, longitude: region.center.longitude)
            mapView.addAnnotation(currentPin)
            mapView.region = region
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self,mapView:$mapView,tapped: $tapped,tapAddress:$tapAddress)
    }
}

extension UIMapAddressGetView{
    class Coordinator: NSObject {
        
        var control: UIMapAddressGetView
        
        @Binding var mapView:MKMapView
        @Binding var tapped:Bool
        @Binding var tapAddress:String
        
        @State var geocoder = CLGeocoder()
        
        init(_ control: UIMapAddressGetView,mapView:Binding<MKMapView>,tapped:Binding<Bool>,tapAddress:Binding<String>){
            self.control = control
            _mapView = mapView
            _tapped = tapped
            _tapAddress = tapAddress
        }
        
        // 長押しされた時に実行されるメソッド
        @objc  func longTapped(_ gesture: UILongPressGestureRecognizer) {
            
            
            let viewPoint = gesture.location(in: mapView)
            let mapCoordinate: CLLocationCoordinate2D = mapView.convert(viewPoint, toCoordinateFrom:mapView)
            let tapAnotation = LocationPin(title: "",latitude:mapCoordinate.latitude, longitude: mapCoordinate.longitude)
            
            if !mapView.annotations.isEmpty{
                mapView.removeAnnotation(mapView.annotations[0])
            }
            
            geocoder.reverseGeocodeLocation(CLLocation(latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)) { [self] placemarks, error in
                if let placemark = placemarks?.first {
                    //住所
                    let administrativeArea = placemark.administrativeArea == nil ? "" : placemark.administrativeArea!
                    let locality = placemark.locality == nil ? "" : placemark.locality!
                    let subLocality = placemark.subLocality == nil ? "" : placemark.subLocality!
                    let thoroughfare = placemark.thoroughfare == nil ? "" : placemark.thoroughfare!
                    let subThoroughfare = placemark.subThoroughfare == nil ? "" : placemark.subThoroughfare!
                    let placeName = !thoroughfare.contains( subLocality ) ? subLocality : thoroughfare
                    self.tapAddress = administrativeArea + locality + placeName + subThoroughfare
                    if self.tapAddress == ""{
                        self.tapAddress = "取得できないエリアです..."
                    }
                }
            }
            self.tapped = true
            
            mapView.addAnnotation(tapAnotation)

        }
        
    }
}
