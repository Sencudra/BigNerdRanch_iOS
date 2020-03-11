//
//  MapViewController.swift
//  WorldTrotter
//
//  Created by Vladislav Tarasevich on 09.03.2020.
//  Copyright © 2020 Vladislav Tarasevich. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

final class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // MARK: - Private properties

    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private var pinIndex = 0

    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        print("MapViewController loaded is's view!")
    }

    override func loadView() {
        super.loadView()

        // Map View
        mapView.delegate = self
        view = mapView

        // Segmeted Control
        let segmentedControl = makeSegmentedControl()
        view.addSubview(segmentedControl)
        makeSegmentedControlConstraints(for: segmentedControl)

        // Location Button
        let locationButton = makeLocationButton()
        view.addSubview(locationButton)
        makeLocationButtonConstraints(for: locationButton)

        // Pin Button
        let pinButton = makePinButton()
        view.addSubview(pinButton)
        makePinButtonConstraints(for: pinButton)

        // Additional constraints
        let topLocationButtonConstraint = locationButton.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor,
                                                                              constant: 8)
        let topPinButtonConstraint = pinButton.topAnchor.constraint(equalTo: locationButton.bottomAnchor,
                                                                    constant: 8)
        topLocationButtonConstraint.isActive = true
        topPinButtonConstraint.isActive = true

        // Add pins
        addPins()
    }

    override func viewWillAppear(_ animated: Bool) {
        print("MapViewController: view will appear!")
    }

    // MARK: - Private methods

    @objc
    private func mapTypeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard

        case 1:
            mapView.mapType = .hybrid

        case 2:
            mapView.mapType = .satellite
    
        default:
            break
        }
    }

    @objc
    private func showLocation(_ sender: UIButton) {
        mapView.userTrackingMode = .follow // Alternative
        mapView.showsUserLocation = true
        locationManager.requestWhenInUseAuthorization()
    }

    @objc func showPin(_ sender: UIButton) {
        let annotation = MapPinAnnotation.all[pinIndex]
        let zoom = MKCoordinateRegion(center: annotation.coordinate,
                                      latitudinalMeters: 500,
                                      longitudinalMeters: 500)
        mapView.setRegion(zoom, animated: true)
        pinIndex = pinIndex < MapPinAnnotation.all.count - 1 ? pinIndex + 1 : 0
        print(pinIndex)
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let zoomedInCurrentLocation = MKCoordinateRegion(center: userLocation.coordinate,
                                                         latitudinalMeters: 500,
                                                         longitudinalMeters: 500)
        mapView.setRegion(zoomedInCurrentLocation, animated: true)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let hash = "\(annotation.hash)"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: hash) as? MKPinAnnotationView
        guard let view = pinView else {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: hash)
            pinView?.canShowCallout = true
            pinView?.animatesDrop = true
            pinView?.pinTintColor = .purple
            return pinView
        }
        print("Resused")
        view.annotation = annotation
        return view
    }

    // MARK: - Private methods

    private func addPins() {
        for annotation in MapPinAnnotation.all {
            mapView.addAnnotation(annotation)
        }
    }

    private func makeSegmentedControl() -> UISegmentedControl {
        let segments = ["Standart", "Hybrid", "Satellite"]
        let segmentedControl = UISegmentedControl(items: segments)
        segmentedControl.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(MapViewController.mapTypeChanged(_:)), for: .valueChanged)
        return segmentedControl
    }

    private func makeLocationButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        button.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.2)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Location", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: #selector(MapViewController.showLocation(_:)), for: .touchUpInside)
        return button
    }

    private func makePinButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        button.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.2)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Pin", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: #selector(MapViewController.showPin(_:)), for: .touchUpInside)
        return button
    }

    private func makeSegmentedControlConstraints(for segmentedControl: UISegmentedControl) {
        let topConstraint = segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                                  constant: 8)

        let margins = view.layoutMarginsGuide
        let leadingConstraint = segmentedControl.leadingAnchor.constraint(equalTo: margins.leadingAnchor)
        let trailingConstraint = segmentedControl.trailingAnchor.constraint(equalTo: margins.trailingAnchor)

        topConstraint.isActive = true
        leadingConstraint.isActive = true
        trailingConstraint.isActive = true
    }

    private func makeLocationButtonConstraints(for button: UIButton) {
        let margins = view.layoutMarginsGuide
        let trailingConstraint = button.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 80)
        let heightConstrant = button.heightAnchor.constraint(equalToConstant: 32)

        widthConstraint.isActive = true
        heightConstrant.isActive = true
        trailingConstraint.isActive = true
    }

    private func makePinButtonConstraints(for button: UIButton) {
        let margins = view.layoutMarginsGuide
        let trailingConstraint = button.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 80)
        let heightConstrant = button.heightAnchor.constraint(equalToConstant: 32)

        widthConstraint.isActive = true
        heightConstrant.isActive = true
        trailingConstraint.isActive = true
    }

}
