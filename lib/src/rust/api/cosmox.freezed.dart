// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cosmox.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SdkError {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SdkError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SdkError()';
}


}

/// @nodoc
class $SdkErrorCopyWith<$Res>  {
$SdkErrorCopyWith(SdkError _, $Res Function(SdkError) __);
}


/// Adds pattern-matching-related methods to [SdkError].
extension SdkErrorPatterns on SdkError {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SdkError_Unauthenticated value)?  unauthenticated,TResult Function( SdkError_ConnectionFailed value)?  connectionFailed,TResult Function( SdkError_HttpError value)?  httpError,TResult Function( SdkError_SerdeError value)?  serdeError,TResult Function( SdkError_Internal value)?  internal,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SdkError_Unauthenticated() when unauthenticated != null:
return unauthenticated(_that);case SdkError_ConnectionFailed() when connectionFailed != null:
return connectionFailed(_that);case SdkError_HttpError() when httpError != null:
return httpError(_that);case SdkError_SerdeError() when serdeError != null:
return serdeError(_that);case SdkError_Internal() when internal != null:
return internal(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SdkError_Unauthenticated value)  unauthenticated,required TResult Function( SdkError_ConnectionFailed value)  connectionFailed,required TResult Function( SdkError_HttpError value)  httpError,required TResult Function( SdkError_SerdeError value)  serdeError,required TResult Function( SdkError_Internal value)  internal,}){
final _that = this;
switch (_that) {
case SdkError_Unauthenticated():
return unauthenticated(_that);case SdkError_ConnectionFailed():
return connectionFailed(_that);case SdkError_HttpError():
return httpError(_that);case SdkError_SerdeError():
return serdeError(_that);case SdkError_Internal():
return internal(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SdkError_Unauthenticated value)?  unauthenticated,TResult? Function( SdkError_ConnectionFailed value)?  connectionFailed,TResult? Function( SdkError_HttpError value)?  httpError,TResult? Function( SdkError_SerdeError value)?  serdeError,TResult? Function( SdkError_Internal value)?  internal,}){
final _that = this;
switch (_that) {
case SdkError_Unauthenticated() when unauthenticated != null:
return unauthenticated(_that);case SdkError_ConnectionFailed() when connectionFailed != null:
return connectionFailed(_that);case SdkError_HttpError() when httpError != null:
return httpError(_that);case SdkError_SerdeError() when serdeError != null:
return serdeError(_that);case SdkError_Internal() when internal != null:
return internal(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  unauthenticated,TResult Function( String field0)?  connectionFailed,TResult Function( int status,  String message)?  httpError,TResult Function( String field0)?  serdeError,TResult Function( String field0)?  internal,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SdkError_Unauthenticated() when unauthenticated != null:
return unauthenticated();case SdkError_ConnectionFailed() when connectionFailed != null:
return connectionFailed(_that.field0);case SdkError_HttpError() when httpError != null:
return httpError(_that.status,_that.message);case SdkError_SerdeError() when serdeError != null:
return serdeError(_that.field0);case SdkError_Internal() when internal != null:
return internal(_that.field0);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  unauthenticated,required TResult Function( String field0)  connectionFailed,required TResult Function( int status,  String message)  httpError,required TResult Function( String field0)  serdeError,required TResult Function( String field0)  internal,}) {final _that = this;
switch (_that) {
case SdkError_Unauthenticated():
return unauthenticated();case SdkError_ConnectionFailed():
return connectionFailed(_that.field0);case SdkError_HttpError():
return httpError(_that.status,_that.message);case SdkError_SerdeError():
return serdeError(_that.field0);case SdkError_Internal():
return internal(_that.field0);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  unauthenticated,TResult? Function( String field0)?  connectionFailed,TResult? Function( int status,  String message)?  httpError,TResult? Function( String field0)?  serdeError,TResult? Function( String field0)?  internal,}) {final _that = this;
switch (_that) {
case SdkError_Unauthenticated() when unauthenticated != null:
return unauthenticated();case SdkError_ConnectionFailed() when connectionFailed != null:
return connectionFailed(_that.field0);case SdkError_HttpError() when httpError != null:
return httpError(_that.status,_that.message);case SdkError_SerdeError() when serdeError != null:
return serdeError(_that.field0);case SdkError_Internal() when internal != null:
return internal(_that.field0);case _:
  return null;

}
}

}

/// @nodoc


class SdkError_Unauthenticated extends SdkError {
  const SdkError_Unauthenticated(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SdkError_Unauthenticated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SdkError.unauthenticated()';
}


}




/// @nodoc


class SdkError_ConnectionFailed extends SdkError {
  const SdkError_ConnectionFailed(this.field0): super._();
  

 final  String field0;

/// Create a copy of SdkError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SdkError_ConnectionFailedCopyWith<SdkError_ConnectionFailed> get copyWith => _$SdkError_ConnectionFailedCopyWithImpl<SdkError_ConnectionFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SdkError_ConnectionFailed&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'SdkError.connectionFailed(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $SdkError_ConnectionFailedCopyWith<$Res> implements $SdkErrorCopyWith<$Res> {
  factory $SdkError_ConnectionFailedCopyWith(SdkError_ConnectionFailed value, $Res Function(SdkError_ConnectionFailed) _then) = _$SdkError_ConnectionFailedCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$SdkError_ConnectionFailedCopyWithImpl<$Res>
    implements $SdkError_ConnectionFailedCopyWith<$Res> {
  _$SdkError_ConnectionFailedCopyWithImpl(this._self, this._then);

  final SdkError_ConnectionFailed _self;
  final $Res Function(SdkError_ConnectionFailed) _then;

/// Create a copy of SdkError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(SdkError_ConnectionFailed(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SdkError_HttpError extends SdkError {
  const SdkError_HttpError({required this.status, required this.message}): super._();
  

 final  int status;
 final  String message;

/// Create a copy of SdkError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SdkError_HttpErrorCopyWith<SdkError_HttpError> get copyWith => _$SdkError_HttpErrorCopyWithImpl<SdkError_HttpError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SdkError_HttpError&&(identical(other.status, status) || other.status == status)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,status,message);

@override
String toString() {
  return 'SdkError.httpError(status: $status, message: $message)';
}


}

/// @nodoc
abstract mixin class $SdkError_HttpErrorCopyWith<$Res> implements $SdkErrorCopyWith<$Res> {
  factory $SdkError_HttpErrorCopyWith(SdkError_HttpError value, $Res Function(SdkError_HttpError) _then) = _$SdkError_HttpErrorCopyWithImpl;
@useResult
$Res call({
 int status, String message
});




}
/// @nodoc
class _$SdkError_HttpErrorCopyWithImpl<$Res>
    implements $SdkError_HttpErrorCopyWith<$Res> {
  _$SdkError_HttpErrorCopyWithImpl(this._self, this._then);

  final SdkError_HttpError _self;
  final $Res Function(SdkError_HttpError) _then;

/// Create a copy of SdkError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? status = null,Object? message = null,}) {
  return _then(SdkError_HttpError(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SdkError_SerdeError extends SdkError {
  const SdkError_SerdeError(this.field0): super._();
  

 final  String field0;

/// Create a copy of SdkError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SdkError_SerdeErrorCopyWith<SdkError_SerdeError> get copyWith => _$SdkError_SerdeErrorCopyWithImpl<SdkError_SerdeError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SdkError_SerdeError&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'SdkError.serdeError(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $SdkError_SerdeErrorCopyWith<$Res> implements $SdkErrorCopyWith<$Res> {
  factory $SdkError_SerdeErrorCopyWith(SdkError_SerdeError value, $Res Function(SdkError_SerdeError) _then) = _$SdkError_SerdeErrorCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$SdkError_SerdeErrorCopyWithImpl<$Res>
    implements $SdkError_SerdeErrorCopyWith<$Res> {
  _$SdkError_SerdeErrorCopyWithImpl(this._self, this._then);

  final SdkError_SerdeError _self;
  final $Res Function(SdkError_SerdeError) _then;

/// Create a copy of SdkError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(SdkError_SerdeError(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SdkError_Internal extends SdkError {
  const SdkError_Internal(this.field0): super._();
  

 final  String field0;

/// Create a copy of SdkError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SdkError_InternalCopyWith<SdkError_Internal> get copyWith => _$SdkError_InternalCopyWithImpl<SdkError_Internal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SdkError_Internal&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'SdkError.internal(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $SdkError_InternalCopyWith<$Res> implements $SdkErrorCopyWith<$Res> {
  factory $SdkError_InternalCopyWith(SdkError_Internal value, $Res Function(SdkError_Internal) _then) = _$SdkError_InternalCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$SdkError_InternalCopyWithImpl<$Res>
    implements $SdkError_InternalCopyWith<$Res> {
  _$SdkError_InternalCopyWithImpl(this._self, this._then);

  final SdkError_Internal _self;
  final $Res Function(SdkError_Internal) _then;

/// Create a copy of SdkError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(SdkError_Internal(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
