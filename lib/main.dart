import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'model/climb_route.dart';
import 'model/climb_route_model.dart';
import 'model/google_sign_in.dart';
import 'model/serializers.dart';

import 'route_viewer.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const ProviderScope(child: MyApp()));
}

final climbRoutesProvider =
    StateNotifierProvider<ClimbRouteNotifier, List<ClimbRoute>>(
        (ref) => ClimbRouteNotifier([]));

final googleSignInProvider =
    StateNotifierProvider<GoogleSignInNotifier, GoogleSignInAccount?>(
        (ref) => GoogleSignInNotifier());

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
        primarySwatch: Colors.lightGreen,
        scaffoldBackgroundColor: Color(0xFFEFEFEF),
        canvasColor: Colors.lightGreen.shade100,
      ),
      home: MyHomePage(title: 'Climb Manager'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  // TODO: fix
  StateNotifierProvider<ClimbRouteNotifier, List<ClimbRoute>>? dataProvider;

  ClimbRouteStorage? storage;

  @override
  void initState() {
    super.initState();
    // _readRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _waitingView();
          } else if (snapshot.hasError) {
            return _errorView();
          } else if (snapshot.hasData && storage != null) {
            return _loggedInView(context);
          } else {
            return _signupView();
          }
        });
  }

  void _createRoute(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RouteViewer(
            climbRoutesProvider: dataProvider!, storage: this.storage!)));
  }

  Future<void> _readRoutes() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    AndroidOptions _getAndroidOptions() => AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: userId,
      // preferencesKeyPrefix: 'Test'
    );
    final localStorage = ClimbRouteStorage(
        secureStorage:
        FlutterSecureStorage(aOptions: _getAndroidOptions()));
    final routes = await localStorage.readClimbRoutes();
    setState(() {
      storage = localStorage;
      dataProvider =
          StateNotifierProvider<ClimbRouteNotifier, List<ClimbRoute>>(
              (ref) => ClimbRouteNotifier(routes));
    });
  }

  Widget _errorView() => Scaffold(
        body: Text('Error'),
      );

  Widget _loggedInView(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
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
                storage: storage!,
              ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              color: Colors.lightGreen.shade300,
              child: DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(user.photoURL!),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('${user.displayName}'),
                    Text('${user.email}'),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.lightGreen.shade300,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Sign out'),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      await ref
                          .read(googleSignInProvider.notifier)
                          .googleSignOut();
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightGreen,
        onPressed: () {
          if (dataProvider != null) {
            _createRoute(context);
          }
        },
        tooltip: 'Add route',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _signupView() {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(32),
        color: Colors.lightGreen,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Welcome!\nTrack your climbs.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Login to your google account!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.white60,
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 32)),
                onPressed: () async {
                  await ref.read(googleSignInProvider.notifier).googleLogin();
                  await _readRoutes();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.google,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text('Sign Up with Google'),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget _waitingView() => Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}

class ClimbRouteStorage {
  final FlutterSecureStorage secureStorage;

  ClimbRouteStorage({required this.secureStorage});

  Future<void> writeClimbRoutes(List<ClimbRoute> climbRoutes) async {
    const serializeType = FullType(BuiltList, [FullType(ClimbRoute)]);
    final jString = serializers.serialize(BuiltList.from(climbRoutes),
        specifiedType: serializeType);
    final data = json.encode(jString);
    secureStorage.write(key: 'routes', value: data);
  }

  Future<List<ClimbRoute>> readClimbRoutes() async {
    final data = await secureStorage.read(key: 'routes');
    if (data == null) {
      return [];
    }
    final routes = serializers.deserialize(json.decode(data),
            specifiedType:
                const FullType(BuiltList, const [const FullType(ClimbRoute)]))
        as BuiltList<ClimbRoute>;
    return routes.toList();
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
    final user = FirebaseAuth.instance.currentUser!;
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
                      radius: 30,
                      backgroundImage: NetworkImage(user.photoURL!),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user.displayName}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('You have complete ${climbRoute.length}' +
                                (climbRoute.length > 1
                                    ? ' challenges'
                                    : ' challenge'))
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
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.black54,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(
                      climbRoute.address,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
