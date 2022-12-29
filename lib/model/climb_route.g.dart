// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'climb_route.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<ClimbRoute> _$climbRouteSerializer = new _$ClimbRouteSerializer();

class _$ClimbRouteSerializer implements StructuredSerializer<ClimbRoute> {
  @override
  final Iterable<Type> types = const [ClimbRoute, _$ClimbRoute];
  @override
  final String wireName = 'ClimbRoute';

  @override
  Iterable<Object?> serialize(Serializers serializers, ClimbRoute object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'level',
      serializers.serialize(object.level,
          specifiedType: const FullType(String)),
      'routeName',
      serializers.serialize(object.routeName,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(int)),
      'address',
      serializers.serialize(object.address,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.imagePath;
    if (value != null) {
      result
        ..add('imagePath')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  ClimbRoute deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ClimbRouteBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'level':
          result.level = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'routeName':
          result.routeName = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'address':
          result.address = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'imagePath':
          result.imagePath = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$ClimbRoute extends ClimbRoute {
  @override
  final String level;
  @override
  final String routeName;
  @override
  final int id;
  @override
  final String address;
  @override
  final String? imagePath;

  factory _$ClimbRoute([void Function(ClimbRouteBuilder)? updates]) =>
      (new ClimbRouteBuilder()..update(updates))._build();

  _$ClimbRoute._(
      {required this.level,
      required this.routeName,
      required this.id,
      required this.address,
      this.imagePath})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(level, r'ClimbRoute', 'level');
    BuiltValueNullFieldError.checkNotNull(
        routeName, r'ClimbRoute', 'routeName');
    BuiltValueNullFieldError.checkNotNull(id, r'ClimbRoute', 'id');
    BuiltValueNullFieldError.checkNotNull(address, r'ClimbRoute', 'address');
  }

  @override
  ClimbRoute rebuild(void Function(ClimbRouteBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ClimbRouteBuilder toBuilder() => new ClimbRouteBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ClimbRoute &&
        level == other.level &&
        routeName == other.routeName &&
        id == other.id &&
        address == other.address &&
        imagePath == other.imagePath;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc($jc($jc($jc(0, level.hashCode), routeName.hashCode), id.hashCode),
            address.hashCode),
        imagePath.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ClimbRoute')
          ..add('level', level)
          ..add('routeName', routeName)
          ..add('id', id)
          ..add('address', address)
          ..add('imagePath', imagePath))
        .toString();
  }
}

class ClimbRouteBuilder implements Builder<ClimbRoute, ClimbRouteBuilder> {
  _$ClimbRoute? _$v;

  String? _level;
  String? get level => _$this._level;
  set level(String? level) => _$this._level = level;

  String? _routeName;
  String? get routeName => _$this._routeName;
  set routeName(String? routeName) => _$this._routeName = routeName;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  String? _imagePath;
  String? get imagePath => _$this._imagePath;
  set imagePath(String? imagePath) => _$this._imagePath = imagePath;

  ClimbRouteBuilder();

  ClimbRouteBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _level = $v.level;
      _routeName = $v.routeName;
      _id = $v.id;
      _address = $v.address;
      _imagePath = $v.imagePath;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ClimbRoute other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$ClimbRoute;
  }

  @override
  void update(void Function(ClimbRouteBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ClimbRoute build() => _build();

  _$ClimbRoute _build() {
    final _$result = _$v ??
        new _$ClimbRoute._(
            level: BuiltValueNullFieldError.checkNotNull(
                level, r'ClimbRoute', 'level'),
            routeName: BuiltValueNullFieldError.checkNotNull(
                routeName, r'ClimbRoute', 'routeName'),
            id: BuiltValueNullFieldError.checkNotNull(id, r'ClimbRoute', 'id'),
            address: BuiltValueNullFieldError.checkNotNull(
                address, r'ClimbRoute', 'address'),
            imagePath: imagePath);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,no_leading_underscores_for_local_identifiers,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new,unnecessary_lambdas
