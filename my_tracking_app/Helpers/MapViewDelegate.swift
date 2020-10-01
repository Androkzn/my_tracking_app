//
//  MapViewDelegate.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-07-13.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import Foundation
import MapKit

protocol MapViewDelegate: MKMapViewDelegate {
    var overlays: [MKPolyline] { get set }
}

// Render the polyline on map
extension MapViewDelegate {

    func renderer(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 3
        return renderer
    }

    func deleteRoute(_ mapView: MKMapView) {
        if !overlays.isEmpty {
            mapView.removeOverlays(overlays)
            overlays.removeAll(keepingCapacity: false)
        }
    }

    func drawRoute(_ mapView: MKMapView,
                   coordinates: [CLLocationCoordinate2D],
                   animateToRoute: Bool) {

        // Reconstruct the whole route to show it whole
        if animateToRoute {
            deleteRoute(mapView)
        }

        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        let padding: CGFloat = 15
        mapView.addOverlay(polyline)
        overlays.append(polyline)

        if animateToRoute {
            let rect = polyline.boundingMapRect
            mapView.setVisibleMapRect(rect,
                                      edgePadding: UIEdgeInsets(
                                        top: 0,
                                        left: padding,
                                        bottom: padding,
                                        right: padding
                                      ),
                                      animated: true)
        }

    }
}
