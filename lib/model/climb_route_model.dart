import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'climb_route.dart';

class ClimbRouteNotifier extends StateNotifier<List<ClimbRoute>> {
  ClimbRouteNotifier(List<ClimbRoute> savedRoutes) : super(savedRoutes);

  void addClimbRoute(ClimbRoute route) {
    state = [...state, route];
  }

  void modifyClimbRoute(ClimbRoute route) {
    state = [
      for (final r in state)
        if (r.id == route.id)
          r.rebuild((r) =>
          r
            ..routeName = route.routeName
            ..level = route.level
            ..address = route.address
            ..imagePath = route.imagePath)
        else
          r,
    ];
  }

  void removeClimbRoute(ClimbRoute route) {
    state = [
    for (final r in state)
      if (r.id != route.id) r,
    ];
  }
}