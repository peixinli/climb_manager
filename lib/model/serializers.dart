import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_collection/built_collection.dart';

import 'climb_route.dart';

part 'serializers.g.dart';

//add all of the built value types that require serialization
@SerializersFor([
  ClimbRoute,
])
final Serializers serializers = (_$serializers.toBuilder()
      ..addPlugin(StandardJsonPlugin())
      ..addBuilderFactory(
          // add this builder factory
          const FullType(BuiltList, const [const FullType(ClimbRoute)]),
          () => new ListBuilder<ClimbRoute>()))
    .build();
