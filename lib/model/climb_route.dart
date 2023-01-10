import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'climb_route.g.dart';

abstract class ClimbRoute implements Built<ClimbRoute, ClimbRouteBuilder> {
  static Serializer<ClimbRoute> get serializer => _$climbRouteSerializer;

  String get level;

  String get routeName;

  int get id;

  String get address;

  String? get imagePath;

  ClimbRoute._();
  factory ClimbRoute([void Function(ClimbRouteBuilder) updates]) = _$ClimbRoute;
}


abstract class PathNode implements Built<PathNode, PathNodeBuilder> {
  static Serializer<PathNode> get serializer => _$pathNodeSerializer;

  double get left;

  double get top;

  PathNode._();

  factory PathNode([void Function(PathNodeBuilder) updates]) = _$PathNode;
}