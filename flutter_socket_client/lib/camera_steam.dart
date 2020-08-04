import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;
// import 'package:tflite/tflite.dart';
import 'dart:math' as math;

// import 'models.dart';

typedef void Callback(List<dynamic> list, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;

  Camera(this.cameras);

  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController controller;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();

    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No camera is found');
    } else {
      controller = new CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller.startImageStream((CameraImage img) {
          // we will get image here
          dynamic imgData = convertYUV420toImageColor(img);
          print("==>");
          print(imgData);
        });
      });
    }
  }

  Future<Image> convertYUV420toImageColor(CameraImage image) async {
    try {
      final int width = image.width;
      final int height = image.height;
      final int uvRowStride = image.planes[1].bytesPerRow;
      final int uvPixelStride = image.planes[1].bytesPerPixel;

      print("uvRowStride: " + uvRowStride.toString());
      print("uvPixelStride: " + uvPixelStride.toString());

      // imgLib -> Image package from https://pub.dartlang.org/packages/image
      var img = imglib.Image(width, height); // Create Image buffer

      // Fill image buffer with plane[0] from YUV420_888
      for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
          final int uvIndex =
              uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
          final int index = y * width + x;

          final yp = image.planes[0].bytes[index];
          final up = image.planes[1].bytes[uvIndex];
          final vp = image.planes[2].bytes[uvIndex];
          // Calculate pixel color
          int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
          int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
              .round()
              .clamp(0, 255);
          int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
          // color: 0x FF  FF  FF  FF
          //           A   B   G   R
          img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
        }
      }

      imglib.PngEncoder pngEncoder = new imglib.PngEncoder(level: 0, filter: 0);
      List<int> png = pngEncoder.encodeImage(img);
      // muteYUVProcessing = false;
      return Image.memory(png);
    } catch (e) {
      print(">>>>>>>>>>>> ERROR:" + e.toString());
    }
    return null;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller),
    );
  }
}
