import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';

import 'model/climb_route.dart';
import 'model/climb_route_model.dart';
import 'model/serializers.dart';

import 'route_viewer.dart';
import 'dart:convert';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final climbRoutesProvider =
    StateNotifierProvider<ClimbRouteNotifier, List<ClimbRoute>>(
        (ref) => ClimbRouteNotifier([]));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFFEFEFEF),
      ),
      home: MyHomePage(title: 'Climb Manager'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  final storage = ClimbRouteStorage();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StateNotifierProvider<ClimbRouteNotifier, List<ClimbRoute>>? dataProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readRoutes();
  }

  void _createRoute(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RouteViewer(
            climbRoutesProvider: dataProvider!, storage: widget.storage)));
  }

  Future<void> readRoutes() async {
    final routes = await widget.storage.readClimbRoutes();
    setState(() {
      dataProvider =
          StateNotifierProvider<ClimbRouteNotifier, List<ClimbRoute>>(
              (ref) => ClimbRouteNotifier(routes));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: dataProvider == null
            ? null
            : _ClimbRouteListView(
                dataProvider: dataProvider!,
                storage: widget.storage,
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightGreen,
        onPressed: () {
          if (climbRoutesProvider != null) {
            _createRoute(context);
          }
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ClimbRouteStorage {
  Future<void> writeClimbRoutes(List<ClimbRoute> climbRoutes) async {
    final directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/data.json');
    if (file.existsSync()) {
      file.deleteSync(recursive: true);
    }
    file =
        await new File('${directory.path}/data.json').create(recursive: true);

    final serializeType =
        const FullType(BuiltList, const [const FullType(ClimbRoute)]);
    final jString = serializers.serialize(BuiltList.from(climbRoutes),
        specifiedType: serializeType);
    final data = json.encode(jString);
    file.writeAsStringSync(data);
  }

  Future<List<ClimbRoute>> readClimbRoutes() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data.json');
    if (!file.existsSync()) {
      return [];
    }
    final data = await file.readAsStringSync();
    final routes = serializers.deserialize(json.decode(data),
            specifiedType:
                const FullType(BuiltList, const [const FullType(ClimbRoute)]))
        as BuiltList<ClimbRoute>;
    return routes.toList();

    //DEBUG
    return [];
  }
}

class _ClimbRouteListView extends ConsumerWidget {
  final StateNotifierProvider<ClimbRouteNotifier, List<ClimbRoute>>?
      dataProvider;

  final ClimbRouteStorage storage;

  const _ClimbRouteListView(
      {required this.dataProvider, required this.storage, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (dataProvider == null) return Container();
    List<ClimbRoute> climbRoute = ref.watch(dataProvider!);
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Profile',
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      child: Text('PL'),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Peixin Li',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('You have climbed ${climbRoute.length}' +
                                (climbRoute.length > 1 ? ' times' : ' time'))
                          ],
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your last challenges',
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: climbRoute.length,
            itemBuilder: (context, index) => GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RouteViewer(
                              climbRoute: climbRoute[index],
                              climbRoutesProvider: dataProvider!,
                              storage: storage,
                            )),
                  ),
                  child: buildCard(context, climbRoute[index]),
                ))
      ],
    );
  }

  Widget buildCard(BuildContext context, ClimbRoute climbRoute) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (climbRoute.imagePath != null)
              Container(
                child: Image.file(
                  File(climbRoute.imagePath!),
                  fit: BoxFit.fitWidth,
                ),
                height: 250,
                width: double.infinity,
                color: Colors.black54,
              ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(12),
                child: Text(climbRoute.level,
                    style: TextStyle(
                        color: Colors.brown, fontWeight: FontWeight.bold)),
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.amber),
              ),
              title: Text(climbRoute.routeName,
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 24),
              child: Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.black54,
                    ),
                    Expanded(
                        child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Text(
                        climbRoute.address,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
