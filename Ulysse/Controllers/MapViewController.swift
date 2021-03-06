import UIKit
import MapKit

func getDouble(value: Any?) -> Double {
  switch value {
  case is String:
    return Double(value as! String) ?? 0
  case is Double:
    return value as! Double
  case is Int:
    return Double(value as! Int)
  default:
    return 0;
  }
}

class MapViewController: UIViewController, MKMapViewDelegate, MKAnnotation {

  var mapView: MKMapView
  var coordinate: CLLocationCoordinate2D
  var needsAnimation: Bool
  var needsMapViewUpdate: Bool
  var isMapViewUpdating: Bool
  var heading: Double
  var locationManager: CLLocationManager = CLLocationManager()

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    self.mapView = MKMapView()
    self.mapView.showsUserLocation = true
    self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    self.needsMapViewUpdate = false
    self.isMapViewUpdating = false
    self.heading = 0
    self.needsAnimation = false
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    self.view = self.mapView
  }

  override func viewDidLoad() {
    self.mapView.delegate = self
    self.mapView.showsCompass = false
    let noLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    let viewRegion: MKCoordinateRegion = MKCoordinateRegion(center: noLocation, latitudinalMeters: 100, longitudinalMeters: 100)
    let adjustedRegion: MKCoordinateRegion = self.mapView.regionThatFits(viewRegion)
    self.mapView.setRegion(adjustedRegion, animated: false)
    self.mapView.addAnnotation(self)
  }

  @objc func update(values: Dictionary<String, Any>) {
    let gpsValues: Dictionary<String, Any>? = values["gps"] as? Dictionary
    if ((gpsValues != nil) && (gpsValues?["lat"] != nil) && (gpsValues?["lon"] != nil)) {
      let latitude: Double = getDouble(value: gpsValues!["lat"])
      let longitude: Double = getDouble(value: gpsValues!["lon"])
      self.needsAnimation = self.coordinate.latitude != 0 || self.coordinate.longitude != 0
      self.willChangeValue(forKey: "coordinate")
      self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      self.didChangeValue(forKey: "coordinate")
      self.needsMapViewUpdate = true
    }
    let hullValues: Dictionary<String, Any>? = values["hll"] as? Dictionary
    if (hullValues != nil && hullValues?["headav"] != nil) {
      self.heading = getDouble(value: hullValues!["headav"])
      self.needsMapViewUpdate = true
    }
    if (self.needsMapViewUpdate) {
      if (!self.isMapViewUpdating) {
        self.updateMapView()
      } else {
        self.needsMapViewUpdate = true
      }
    }
  }

  func updateMapView() {
    self.needsMapViewUpdate = false;
    self.mapView.camera.heading = self.heading;
    self.mapView.setCenter(self.coordinate, animated:self.needsAnimation)
  }

// MARK: - MKMapViewDelegate

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if !(annotation is MapViewController) {
      return nil
    }
    let pinView: MKAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "boat")
    pinView.canShowCallout = false
    pinView.image = UIImage(named: "quickaction_icon_location")
    return pinView
  }

  func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    self.isMapViewUpdating = true
  }

  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    self.isMapViewUpdating = false
    if (self.needsMapViewUpdate) {
      self.updateMapView()
    }
  }

}
