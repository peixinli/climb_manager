import 'dart:io';

import 'package:climb_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' as geocoder;
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import 'model/climb_route.dart';
import 'model/climb_route_model.dart';

class RouteViewer extends ConsumerStatefulWidget {
  final ClimbRoute? climbRoute;

  final StateNotifierProvider<ClimbRouteNotifier, List<ClimbRoute>>
      climbRoutesProvider;

  final ClimbRouteStorage storage;

  const RouteViewer({required this.climbRoutesProvider, required this.storage, this.climbRoute});

  @override
  ConsumerState<RouteViewer> createState() => _RouteViewerState();
}

class _RouteViewerState extends ConsumerState<RouteViewer> {
  TextEditingController nameController = TextEditingController();

  TextEditingController levelController = TextEditingController();

  String? _address;

  bool _fetchedLocation = false;

  String? _imagePath;

  @override
  void initState() {
    setCurrentLocation();
    print('climbRoute ${widget.climbRoute}');
    if (widget.climbRoute != null) {
      _imagePath = widget.climbRoute!.imagePath;
      nameController
        ..text = widget.climbRoute?.routeName ?? '';
      levelController
        ..text = (widget.climbRoute?.level ?? '');
    }
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.lightGreen,
          title: Text(pageTitle()),
          actions: [
            if (widget.climbRoute != null)
              IconButton(
                  onPressed: () {
                    ref
                        .read(widget.climbRoutesProvider.notifier)
                        .removeClimbRoute(widget.climbRoute!);
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.delete)),
            IconButton(
                onPressed: () {
                  save();
                  Navigator.pop(context);
                },
                icon: Icon(Icons.save_alt_rounded))
          ],
        ),
        body: SingleChildScrollView(
          child: editView(context),
        ));
  }

  Widget editView(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
                hintText: 'Enter the route name', labelText: 'Route Name'),
          ),
          TextFormField(
            controller: levelController,
            decoration: InputDecoration(
                hintText: 'Enter the route level', labelText: 'Route level'),
          ),
          if (_imagePath == null)
            Column(
              children: [
                Container(
                  decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          side: BorderSide(width: 1, color: Colors.black54))),
                  padding: EdgeInsets.symmetric(vertical: 74),
                  margin: EdgeInsets.fromLTRB(0, 32, 0, 12),
                  child: Center(
                    child: IconButton(
                      icon: Icon(Icons.add_a_photo),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        getImage(context);
                      },
                    ),
                  ),
                ),
                Text(
                  'Add route image',
                  textAlign: TextAlign.left,
                ),
              ],
            )
          else
            Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    TextButton(onPressed: () {
                      getImage(context);
                    }, child: Text('Select another photo',style: TextStyle(color: Colors.blueGrey),)),
                    Image.file(File(_imagePath!),
                        height: 250, fit: BoxFit.cover),
                  ],
                )),
          Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Row(
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.location_on, color: Colors.black54,)),
                if (!_fetchedLocation && _address == null)
                  Text('Location not found', style: TextStyle(color: Colors.black54),)
                else
                  Text(_address ?? 'Error', style: TextStyle(color: Colors.black54),),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.black54 ),
              onPressed: () {
                save();
                Navigator.pop(context);
              },
              child: Text('Save'))
        ],
      ),
    );
  }

  void save() {
    print('save');
    final currentRoutes = ref.watch(widget.climbRoutesProvider);
    if (widget.climbRoute == null) {
      var newRoute = ClimbRoute((b) => b
        ..id = (currentRoutes.isEmpty ? 0 : currentRoutes.last.id + 1)
        ..routeName = nameController.text
        ..level = levelController.text
        ..address = _address);
      if (_imagePath != null) {
        newRoute = (newRoute.toBuilder()..imagePath = _imagePath).build();
      }
      ref.read(widget.climbRoutesProvider.notifier).addClimbRoute(newRoute);
    } else {
      ref
          .read(widget.climbRoutesProvider.notifier)
          .modifyClimbRoute(ClimbRoute((b) => b
            ..id = widget.climbRoute!.id
            ..routeName = nameController.text
            ..level = levelController.text
            ..imagePath = _imagePath
            ..address = _address));
    }
    widget.storage.writeClimbRoutes(ref.watch(widget.climbRoutesProvider));
  }

  void setCurrentLocation() async {
    if (widget.climbRoute != null) {
      setState(() {
        _address = widget.climbRoute!.address;
        _fetchedLocation = true;
      });
    }
    final location = new Location();
    final serviceEnabled = await location.requestService();
    if (!serviceEnabled) return;

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted == PermissionStatus.denied) return;
    }
    final locationData = await location.getLocation();
    if (locationData.longitude != null && locationData.altitude != null) {
      var placemarks;
      try {
        placemarks = await geocoder.placemarkFromCoordinates(
            locationData.latitude!, locationData.longitude!);
      } catch (e) {
      }

      final placemark = placemarks.first;
      setState(() {
        _address =
            '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}';
        _fetchedLocation = true;
      });
    }
  }

  String pageTitle() =>
      widget.climbRoute == null ? 'Add a new route' : 'Edit your route';

  Future<ImageSource?> pickSource(BuildContext context) async {
    return showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Choose image from: '),
            children: <Widget>[
              SimpleDialogOption(
                child: Row(children: [
                  Icon(Icons.image_outlined),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('gallery'))
                ]),
                onPressed: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
              SimpleDialogOption(
                child: Row(children: [
                  Icon(Icons.camera),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('camera'))
                ]),
                onPressed: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              )
            ],
          );
        });
  }

  Future<void> getImage(BuildContext context) async {
    final source = await pickSource(context);
    if (source == null) {
      return;
    }
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final name = basename(image.path);

      final newImage = File('${directory.path}/$name');
      File(image.path).copy(newImage.path);

      setState(() {
        _imagePath = newImage.path;
        print('image path $_imagePath');
      });
    } on PlatformException catch (e) {}
  }
}
