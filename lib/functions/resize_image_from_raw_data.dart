import 'dart:ui' as ui;

import 'package:flutter/services.dart';

// Use this method if you don't have a direct access to the image file
// Like you have the image coming form an API or a different source
Future<Uint8List> resizeImageFromRawData(
  String imagePath,
  double width,
) async {
  // Load the image data from assets
  var imageData = await rootBundle.load(imagePath);

  // Instantiate the image codec with the loaded data and target width
  // Note: This step will resize the image to the specified width
  var imageCodec = await ui.instantiateImageCodec(
    imageData.buffer.asUint8List(),
    targetWidth: width.round(),
  );

  // Get the first frame of the image codec
  var imageFrameInfo = await imageCodec.getNextFrame();

  // Convert the image to a byte array
  // using the specified format (PNG in this case)
  var imageByteData = await imageFrameInfo.image.toByteData(
    format: ui.ImageByteFormat.png,
  );

  // Return the byte array as Uint8List
  return imageByteData!.buffer.asUint8List();
}
