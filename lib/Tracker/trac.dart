import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gpx/gpx.dart';
import '../Views/HomePage.dart';

var gpx;
// Create a track
var track;
// Create a track segment
var segment;
var trkpt;
StreamSubscription<Position>? _positionStreamSubscription;

Future<void> listenLocation() async {
  gpx = new Gpx();
  track = new Trk();
  segment = new Trkseg();

  _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) async {
    await FirebaseFirestore.instance.collection('location').doc(myUid).set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'name': name.toString(),
      'isActive': true
    }, SetOptions(merge: true));

    // Create a track point with latitude, longitude, and time information
    final trackPoint = Wpt(
      lat: position.latitude,
      lon: position.longitude,
      time: DateTime.now(),
    );

    segment.trkpts.add(trackPoint);

    if (track.trksegs.isEmpty) {
      track.trksegs.add(segment);
      gpx.trks.add(track);
    }

    final gpxString = GpxWriter().asString(gpx, pretty: true);
    print("XXX $gpxString");
  });
}

  void stopListeningnew() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  getLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition();
      await FirebaseFirestore.instance.collection('location').doc(myUid).set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'name': name.toString(),
        'isActive': false
      }, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }

