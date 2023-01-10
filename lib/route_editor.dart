import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

import 'model/climb_route.dart';

class RouteEditor extends StatefulWidget {
  final String imagePath;

  void Function(String savedImage) onImageSaved;

  RouteEditor({required this.imagePath, required this.onImageSaved});

  @override
  State<RouteEditor> createState() => _RouteEditorState();
}

class _RouteEditorState extends State<RouteEditor> {
  List<PathNode> nodes = [];

  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    // TODO: implement initState
    // TEST
    nodes = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
        title: Text('Visualize your route'),
        actions: [
          IconButton(
              onPressed: () {
                save();
                Navigator.pop(context);
              },
              icon: Icon(Icons.save_alt_rounded))
        ]);

    return WillPopScope(
      onWillPop: () async {
        return !Navigator.of(context).userGestureInProgress;
      },
      child: Scaffold(
        appBar: appBar,
        body: imageEditor(),
      ),
    );
  }

  Widget imageEditor() {
    return SafeArea(
      child: SizedBox(
        // height: MediaQuery.of(context).size.height * 0.7,
        child: Container(
          alignment: Alignment.center,
          child: Builder(
            builder: (context) => GestureDetector(
              onTapUp: (details) {
                final renderBox = context.findRenderObject() as RenderBox;
                final offset = renderBox.globalToLocal(details.globalPosition);
                setState(() {
                  nodes.add(PathNode((b) => b
                    ..left = offset.dx - 10
                    ..top = offset.dy - 10));
                });
              },
              child: Screenshot(
                controller: screenshotController,
                child: Stack(
                  children: [
                    Image.file(File(widget.imagePath)),
                    for (var i = 0; i < nodes.length; i++)
                      Positioned(
                        left: nodes[i].left,
                        top: nodes[i].top,
                        child: Draggable(
                          feedback: CircledNumber(
                            number: i,
                          ),
                          onDragEnd: (details) {
                            final renderBox =
                                context.findRenderObject() as RenderBox;
                            final offset =
                                renderBox.globalToLocal(details.offset);
                            setState(() {
                              nodes[i] = PathNode((b) => b
                                ..left = offset.dx
                                ..top = offset.dy);
                            });
                          },
                          child: CircledNumber(
                            number: i,
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void save() async {
    final capturedImage = await screenshotController.capture();
    bool isGranted = false;
    if (await Permission.photos.isGranted) {
      isGranted = true;
    } else {
      final p = await Permission.photos.request();
      isGranted = p.isGranted;
    }

    if (isGranted) {
      final time = DateTime.now()
          .toIso8601String()
          .replaceAll('.', '-')
          .replaceAll(':', '-');
      final name = 'screenshot_$time.png';
      final result =
          await ImageGallerySaver.saveImage(capturedImage!, name: name);

      final directory = await getApplicationDocumentsDirectory();
      final newImage = File('${directory.path}/$name');
      await newImage.writeAsBytes(capturedImage);
      widget.onImageSaved(newImage.path);
    }
  }
}

class CircledNumber extends StatelessWidget {
  final int number;

  CircledNumber({required this.number});

  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      // color: Colors.red,
      child: Center(
          child: Text(
        '$number',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
      )),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.deepPurple,
          border: Border.all(color: Colors.deepOrange, width: 2)),
    );
  }
}
