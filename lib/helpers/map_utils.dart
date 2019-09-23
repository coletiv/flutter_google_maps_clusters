import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapHelper {
  /// If there is a cached file and it's not old returns the cached marker image file
  /// else it will download the image and save it on the temp dir and return that file.
  ///
  /// This mechanism is useful to improve load times on the next map loads, the first time
  /// will always take more time to download the file.
  ///
  /// You can resize the marker image by providing a [targetWidth]
  static Future<BitmapDescriptor> getMarkerImageFromUrl(
    String url, {
    int targetWidth,
  }) async {
    assert(url != null);

    final File markerImageFile = await DefaultCacheManager().getSingleFile(url);

    Uint8List markerImageBytes = await markerImageFile.readAsBytes();

    if (targetWidth != null) {
      markerImageBytes = await _resizeImageBytes(
        markerImageBytes,
        targetWidth,
      );
    }

    return BitmapDescriptor.fromBytes(markerImageBytes);
  }

  /// Resizes the given [imageBytes] with the [targetWidth].
  ///
  /// We don't want the marker image to be too big so we might need to resize the image.
  static Future<Uint8List> _resizeImageBytes(
    Uint8List imageBytes,
    int targetWidth,
  ) async {
    assert(imageBytes != null);
    assert(targetWidth != null);

    final Codec imageCodec = await instantiateImageCodec(
      imageBytes,
      targetWidth: targetWidth,
    );

    final FrameInfo frameInfo = await imageCodec.getNextFrame();

    final ByteData byteData = await frameInfo.image.toByteData(
      format: ImageByteFormat.png,
    );

    return byteData.buffer.asUint8List();
  }
}
