import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'model/climb_route.dart';
import 'model/climb_route_model.dart';
import 'route_viewer.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final climbRoutesProvider =
    StateNotifierProvider<ClimbRouteNotifier, List<ClimbRoute>>(
        (ref) => ClimbRouteNotifier());

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
      ),
      home: const MyHomePage(title: 'Climb Manager'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _ClimbRouteListView extends ConsumerWidget {
  const _ClimbRouteListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<ClimbRoute> climbRoute = ref.watch(climbRoutesProvider);
    return Container(
      color: Colors.black12,
      child: Column(
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
                      )
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
                              climbRouteProvider: climbRoutesProvider)),
                    ),
                    child: buildCard(context, climbRoute[index]),
                  ))
        ],
      ),
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

class _MyHomePageState extends State<MyHomePage> {
  void _createRoute() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            RouteViewer(climbRouteProvider: climbRoutesProvider)));
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
        child: _ClimbRouteListView(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightGreen,
        onPressed: _createRoute,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
