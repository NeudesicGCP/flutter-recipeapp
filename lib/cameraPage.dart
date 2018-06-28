
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'Util/utils.dart';
import 'package:flutter/services.dart';

List<CameraDescription> cameras = [];



class CameraExampleHome extends StatefulWidget {
  final Function imageCapturedListener;
  static int pictureCount = 0;
  String imagePath;

  @override
  CameraExampleHome({Key key, this.imageCapturedListener}) : super(key: key);

  @override
  _CameraExampleHomeState createState() {
    return new _CameraExampleHomeState();
  }
}

IconData cameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw new ArgumentError('Unknown lens direction');
}

class _CameraExampleHomeState extends State<CameraExampleHome> {
  bool opening = false;
  CameraController controller;

  @override
  void initState() {
    super.initState();
    getCameras();
  }

  Future<Null> getCameras() async {
    cameras = await availableCameras();
    setState(() {});
  }

  void initializeController(CameraDescription cameraDescription) async {
    try
    {
        final CameraController tempController = controller;
        controller = null;
        await tempController?.dispose();
        controller = new CameraController(cameraDescription, ResolutionPreset.high);
        await controller.initialize();
        setState(() {});
    }
    catch (e) {}
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  bool loaded = false;
  @override
  Widget build(BuildContext context) {
    final List<Widget> headerChildren = <Widget>[];

    final List<Widget> cameraList = <Widget>[];

    if (cameras == null || cameras.isEmpty) {
      cameraList.add(const Text('No cameras found'));
    } else {
        //Set first camera to show
        if (!loaded) {
          initializeController(cameras[0]);
          loaded = true;
        }
      
    }

    headerChildren.add(new Column(children: cameraList));
    headerChildren.add(new Container(
      alignment: AlignmentDirectional.centerEnd,
      child: new FlatButton(
        child: new Text("Done", textAlign: TextAlign.right),
          onPressed: () {
            Navigator.pop(context);
          }
        ),
      )
    );

    final List<Widget> columnChildren = <Widget>[];
    columnChildren.add(new Row(children: headerChildren, mainAxisAlignment: MainAxisAlignment.end,));
    if (controller != null && controller.value != null && controller.value.hasError) {
      columnChildren.add(
        new Text('Camera error ${controller?.value?.errorDescription ?? 'error'}'),
      );
    } else {
      if (controller != null && controller.value != null) {
        columnChildren.add(
          new Expanded(
            child: new Padding(
              padding: const EdgeInsets.all(5.0),
              child: new Center(
                child: controller == null ? new Text("Loading...") : new AspectRatio(
                  aspectRatio: controller?.value?.previewSize != null ? controller?.value?.aspectRatio : 1.0,
                  child: controller != null && controller.value != null ? new CameraPreview(controller) : new Text("Loading..."),
                ),
              ),
            ),
          ),
        );
      }
    }
    columnChildren.add(
      new Container(
        child: new IconButton(
          icon: new Icon(Icons.camera),
          onPressed: () {
            if (controller?.value?.isStarted ?? false) {
              capture();
            }
          },
        )
      )
    );
    return new Container(
      child: new Column(children: columnChildren),
    );
  }

  Future<Null> capture() async {
    if (controller?.value?.isStarted ?? false) {
      print("capturing");
      final Directory tempDir = await getTemporaryDirectory();
      if (!mounted) {
        return;
      }
      final String tempPath = tempDir.path;
      final String path = '$tempPath/picture${CameraExampleHome.pictureCount++}.jpg';
      
      imageCache.clear();
    
      await controller.capture(path);
      if (!mounted) {
        return;
      }
      setState(
        () {
          widget.imagePath = path;
          widget.imageCapturedListener(path);
        },
      );
    }
  }
}