import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_google_maps_clusters/helpers/map_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _mapController = Completer();

  /// Set of displayed markers on the map
  final Set<Marker> _markers = Set();

  /// Map loading flag
  bool _isMapLoading = true;

  /// Markers loading flag
  bool _areMarkersLoading = true;

  final String _markerImageUrl1 =
      'https://img.icons8.com/office/80/000000/marker.png';
  final String _markerImageUrl2 =
      'https://img.icons8.com/ultraviolet/80/000000/marker.png';

  /// A list of a predefined marker locations around Porto
  final List<LatLng> _markerLocations = [
    LatLng(41.147125, -8.611249),
    LatLng(41.145599, -8.610691),
    LatLng(41.145645, -8.614761),
    LatLng(41.146775, -8.614913),
    LatLng(41.146982, -8.615682),
    LatLng(41.140558, -8.611530),
    LatLng(41.138393, -8.608642),
    LatLng(41.137860, -8.609211),
    LatLng(41.138344, -8.611236),
    LatLng(41.139813, -8.609381),
  ];

  /// Called when the Google Map widget is created. Updates the map loading state
  /// and inits the markers.
  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);

    setState(() {
      _isMapLoading = false;
    });

    _initMarkers();
  }

  /// Inits all the markers with network images and updates the loading state.
  void _initMarkers() async {
    for (LatLng markerLocation in _markerLocations) {
      final int markerIndex = _markerLocations.indexOf(markerLocation);

      final String markerImageUrl =
          markerIndex < 5 ? _markerImageUrl1 : _markerImageUrl2;

      final BitmapDescriptor markerImage =
          await MapHelper.getMarkerImageFromUrl(markerImageUrl);

      _markers.add(
        Marker(
          markerId: MarkerId(markerIndex.toString()),
          position: markerLocation,
          icon: markerImage,
        ),
      );
    }

    setState(() {
      _areMarkersLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Markers and Clusters Example'),
      ),
      body: Stack(
        children: <Widget>[
          Opacity(
            opacity: _isMapLoading ? 0 : 1,
            child: GoogleMap(
              mapToolbarEnabled: false,
              compassEnabled: true,
              initialCameraPosition: CameraPosition(
                target: LatLng(41.143029, -8.611274),
                zoom: 15,
              ),
              markers: _markers,
              onMapCreated: (controller) => _onMapCreated(controller),
            ),
          ),
          Opacity(
            opacity: _isMapLoading ? 1 : 0,
            child: Center(child: CircularProgressIndicator()),
          ),
          if (_areMarkersLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Card(
                  elevation: 2,
                  color: Colors.grey.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      'Loading',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
