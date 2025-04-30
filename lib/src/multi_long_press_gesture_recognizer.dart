import 'dart:async';

import 'package:flutter/gestures.dart';

/// Callback signature for [MultiLongPressGestureRecognizer.onMultiLongPressDown].
///
/// Called when a pointer that might cause a long-press has contacted the
/// screen. The position at which the pointer contacted the screen is available
/// in the `details`.
///
/// See also:
///
///  * [GestureMultiLongPressCallback], the signature that gets called when the
///    pointer has been in contact with the screen long enough to be considered
///    a long-press.
typedef GestureMultiLongPressDownCallback = void Function(
    MultiLongPressDownDetails details);

/// Callback signature for [MultiLongPressGestureRecognizer.onMultiLongPressCancel].
///
/// Called when any pointer that previously helped triggering a
/// [GestureMultiLongPressDownCallback] ends up leaving the screen
/// and therefore cancels this gesture.
typedef GestureMultiLongPressCancelCallback = void Function();

/// Callback signature for [MultiLongPressGestureRecognizer.onMultiLongPress].
///
/// Called when a pointer has remained in contact with the screen at the
/// same location for a long period of time. Also reports the long press down
/// position.
typedef GestureMultiLongPressCallback = void Function(
    MultiLongPressDetails details);

/// Callback signature for [MultiLongPressGestureRecognizer.onMultiLongPressMoveUpdate].
///
/// Called when a pointer is moving after being held in contact at the same
/// location for a long period of time. Reports the new position and its offset
/// from the original down position.
typedef GestureMultiLongPressMoveUpdateCallback = void Function(
    MultiLongPressMoveUpdateDetails details);

/// Callback signature for [MultiLongPressGestureRecognizer.onMultiLongPressUp].
///
/// Called when a pointer stops contacting the screen after a long press
/// gesture was detected.
typedef GestureMultiLongPressUpCallback = void Function(
    MultiLongPressUpDetails details);

/// Details for callbacks that use [GestureMultiLongPressDownCallback].
///
/// See also:
///
///  * [MultiLongPressGestureRecognizer.onMultiLongPressDown], whose callback passes
///    these details.
class MultiLongPressDownDetails {
  /// Creates the details for a [GestureMultiLongPressDownCallback].
  ///
  /// The `globalPosition` argument must not be null.
  ///
  /// If the `localPosition` argument is not specified, it will default to the
  /// global position.
  const MultiLongPressDownDetails({
    this.globalPosition = Offset.zero,
    Offset? localPosition,
    this.kind,
  }) : localPosition = localPosition ?? globalPosition;

  /// The global position at which the pointer contacted the screen.
  final Offset globalPosition;

  /// The kind of the device that initiated the event.
  final PointerDeviceKind? kind;

  /// The local position at which the pointer contacted the screen.
  final Offset localPosition;

  @override
  String toString() {
    return "MultiLongPressDownDetails{globalPosition: $globalPosition, kind: $kind, localPosition: $localPosition}";
  }
}

/// Details for callbacks that use [GestureMultiLongPressCallback].
///
/// See also:
///
///  * [MultiLongPressGestureRecognizer.onMultiLongPress], which uses [GestureMultiLongPressCallback].
///  * [MultiLongPressMoveUpdateDetails], the details for [GestureMultiLongPressMoveUpdateCallback]
///  * [MultiLongPressUpDetails], the details for [GestureMultiLongPressUpCallback].
class MultiLongPressDetails {
  /// Creates the details for a [GestureMultiLongPressCallback].
  const MultiLongPressDetails({
    this.globalPositions = const {},
    Map<int, Offset>? localPositions,
  }) : localPositions = localPositions ?? globalPositions;

  /// The global positions at which the pointers initially contacted the screen.
  final Map<int, Offset> globalPositions;

  /// The local positions at which the pointers initially contacted the screen.
  final Map<int, Offset> localPositions;

  @override
  String toString() {
    return "MultiLongPressDetails{globalPositions: $globalPositions, localPositions: $localPositions}";
  }
}

/// Details for callbacks that use [GestureMultiLongPressMoveUpdateCallback].
///
/// See also:
///
///  * [MultiLongPressGestureRecognizer.onMultiLongPressMoveUpdate], which uses [GestureMultiLongPressMoveUpdateCallback].
///  * [MultiLongPressUpDetails], the details for [GestureMultiLongPressUpCallback]
///  * [MultiLongPressDetails], the details for [GestureMultiLongPressCallback].
class MultiLongPressMoveUpdateDetails {
  /// Creates the details for a [GestureMultiLongPressMoveUpdateCallback].
  ///
  /// The [globalPosition] and [offsetFromOrigin] arguments must not be null.
  const MultiLongPressMoveUpdateDetails({
    this.globalPosition = Offset.zero,
    Offset? localPosition,
    this.offsetFromOrigin = Offset.zero,
    Offset? localOffsetFromOrigin,
  })  : localPosition = localPosition ?? globalPosition,
        localOffsetFromOrigin = localOffsetFromOrigin ?? offsetFromOrigin;

  /// The global position of the pointer when it triggered this update.
  final Offset globalPosition;

  /// The local position of the pointer when it triggered this update.
  final Offset localPosition;

  /// A delta offset from the point where the long press drag initially contacted
  /// the screen to the point where the pointer is currently located (the
  /// present [globalPosition]) when this callback is triggered.
  final Offset offsetFromOrigin;

  /// A local delta offset from the point where the long press drag initially contacted
  /// the screen to the point where the pointer is currently located (the
  /// present [localPosition]) when this callback is triggered.
  final Offset localOffsetFromOrigin;

  @override
  String toString() {
    return "MultiLongPressMoveUpdateDetails{globalPosition: $globalPosition, localPosition: $localPosition, offsetFromOrigin: $offsetFromOrigin, localOffsetFromOrigin: $localOffsetFromOrigin}";
  }
}

/// Details for callbacks that use [GestureMultiLongPressUpCallback].
///
/// See also:
///
///  * [MultiLongPressGestureRecognizer.onMultiLongPressUp], which uses [GestureMultiLongPressUpCallback].
///  * [MultiLongPressMoveUpdateDetails], the details for [GestureMultiLongPressMoveUpdateCallback].
///  * [MultiLongPressDetails], the details for [GestureMultiLongPressCallback].
class MultiLongPressUpDetails {
  /// Creates the details for a [GestureMultiLongPressUpCallback].
  ///
  /// The [globalPosition] argument must not be null.
  const MultiLongPressUpDetails({
    this.globalPosition = Offset.zero,
    Offset? localPosition,
  }) : localPosition = localPosition ?? globalPosition;

  /// The global position at which the pointer lifted from the screen.
  final Offset globalPosition;

  /// The local position at which the pointer contacted the screen.
  final Offset localPosition;

  @override
  String toString() {
    return "MultiLongPressUpDetails{globalPosition: $globalPosition, localPosition: $localPosition}";
  }
}

/// Recognizes when the user has pressed down multiple pointers at the same location for a long
/// period of time.
///
/// The gesture must not deviate in position from its touch down point for a specified duration
/// until it's recognized. Once the gesture is accepted, the finger can be
/// moved, triggering [onMultiLongPressMoveUpdate] callbacks, unless the
/// [postAcceptSlopTolerance] constructor argument is specified.
///
/// [MultiLongPressGestureRecognizer] may compete any pointer events if at least
/// one corresponding callback is non-null. If it has no callbacks, it is a no-op.
class MultiLongPressGestureRecognizer extends OneSequenceGestureRecognizer {
  final Duration deadline;
  final double? preAcceptSlopTolerance;
  final double? postAcceptSlopTolerance;
  final int pointerThreshold;

  Timer? _timer;
  int _pointerCounter = 0;
  bool _longPressAccepted = false;
  final Map<int, OffsetPair> _initialOffsets = {};

  GestureRecognizerState get state => _state;
  GestureRecognizerState _state = GestureRecognizerState.ready;

  /// Creates a multi long-press gesture recognizer.
  ///
  /// Consider assigning the [onMultiLongPress] callback after creating this
  /// object.
  ///
  /// Gestures based on this class will stop tracking the gesture if the primary
  /// pointer travels beyond [preAcceptSlopTolerance] or [postAcceptSlopTolerance]
  /// pixels from the original contact point of the gesture.
  ///
  /// The [preAcceptSlopTolerance] argument can be used to specify a maximum
  /// allowed distance for the gesture to deviate from the starting point before
  /// the long press has triggered. If the gesture deviates past that point,
  /// [onMultiLongPressCancel] is called. Defaults to [kTouchSlop].
  ///
  /// The [postAcceptSlopTolerance] argument can be used to specify a maximum
  /// allowed distance for the gesture to deviate from the starting point once
  /// the long press has triggered. If the gesture deviates past that point,
  /// subsequent callbacks ([onMultiLongPressMoveUpdate], [onMultiLongPressUp],
  /// [onMultiLongPressCancel]) will stop. Defaults to null, which means the gesture
  /// can be moved without limit once the long press is accepted.
  ///
  /// The [duration] argument can be used to overwrite the default duration
  /// ([kLongPressTimeout]) after which the long press will be recognized.
  ///
  /// {@macro flutter.gestures.GestureRecognizer.supportedDevices}
  MultiLongPressGestureRecognizer({
    Duration? duration,
    double? preAcceptSlopTolerance,
    this.postAcceptSlopTolerance,
    required this.pointerThreshold,
    super.supportedDevices,
    super.debugOwner,
  })  : deadline = duration ?? kLongPressTimeout,
        preAcceptSlopTolerance = preAcceptSlopTolerance ?? kTouchSlop;

  /// Called when enough pointers have contacted the screen at a particular location
  /// which might be the start of a multi-long-press.
  ///
  /// This triggers after the pointer down event.
  ///
  /// If this recognizer doesn't win the arena, [onMultiLongPressCancel] is called
  /// next. Otherwise, [onMultiLongPress] is called next.
  ///
  /// See also:
  ///
  ///  * [MultiLongPressDownDetails], which is passed as an argument to this callback.
  GestureMultiLongPressDownCallback? onMultiLongPressDown;

  /// Called when any pointer that previously helped triggering [onMultiLongPressDown]
  /// ends up leaving the screen and therefore cancels this gesture.
  ///
  /// This triggers once the gesture loses the arena if [onMultiLongPressDown] has
  /// previously been triggered.
  ///
  /// If this recognizer wins the arena, [onMultiLongPress] is called instead.
  ///
  /// If the gesture is deactivated due to [postAcceptSlopTolerance] having
  /// been exceeded, this callback will not be called, since the gesture will
  /// have already won the arena at that point.
  GestureMultiLongPressCancelCallback? onMultiLongPressCancel;

  /// Called when a multi-long-press gesture has been recognized.
  ///
  /// See also:
  ///
  ///  * [MultiLongPressDetails], which is passed as an argument to this callback.
  GestureMultiLongPressCallback? onMultiLongPress;

  /// Called when moving after the multi-long-press has been recognized.
  ///
  /// See also:
  ///
  ///  * [MultiLongPressMoveUpdateDetails], which is passed as an argument to this
  ///    callback.
  GestureMultiLongPressMoveUpdateCallback? onMultiLongPressMoveUpdate;

  /// Called when any pointer that helped trigger the gesture
  /// stops contacting the screen after a recognized multi-long-press.
  ///
  /// See also:
  ///
  ///  * [MultiLongPressUpDetails], which is passed as an argument to this
  ///    callback.
  GestureMultiLongPressUpCallback? onMultiLongPressUp;

  @override
  String get debugDescription => "multi long press";

  @override
  bool isPointerAllowed(PointerDownEvent event) {
    if (onMultiLongPressDown == null &&
        onMultiLongPressCancel == null &&
        onMultiLongPress == null &&
        onMultiLongPressMoveUpdate == null &&
        onMultiLongPressUp == null) {
      return false;
    }
    return super.isPointerAllowed(event);
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    if (state == GestureRecognizerState.ready) {
      _state = GestureRecognizerState.possible;
    }
    _initialOffsets[event.pointer] =
        OffsetPair(local: event.localPosition, global: event.position);

    if (state == GestureRecognizerState.possible) {
      if (_pointerCounter == pointerThreshold) {
        _stopTimer();
        _timer = Timer(deadline, () {
          didExceedDeadline(event.pointer);
        });
      } else if (_pointerCounter > pointerThreshold) {
        stopTrackingPointer(event.pointer);
      }
    } else {
      _stopTimer();
    }
  }

  @override
  void handleNonAllowedPointer(PointerDownEvent event) {
    if (!_longPressAccepted) {
      super.handleNonAllowedPointer(event);
    }
  }

  @override
  void startTrackingPointer(int pointer, [Matrix4? transform]) {
    super.startTrackingPointer(pointer, transform);
    _pointerCounter++;
  }

  @override
  void stopTrackingPointer(int pointer) {
    if (!_longPressAccepted) {
      _stopTimer();
      resolve(GestureDisposition.rejected);
    }

    if (_initialOffsets.containsKey(pointer)) {
      _initialOffsets.remove(pointer);
    }
    _pointerCounter--;
    super.stopTrackingPointer(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    assert(state != GestureRecognizerState.ready);
    _stopTimer();
    _state = GestureRecognizerState.ready;
    _initialOffsets.clear();
    _reset();
  }

  @override
  void handleEvent(PointerEvent event) {
    assert(state != GestureRecognizerState.ready);
    if (state == GestureRecognizerState.possible) {
      final bool isPreAcceptSlopPastTolerance = !_longPressAccepted &&
          preAcceptSlopTolerance != null &&
          _getGlobalDistance(event) > preAcceptSlopTolerance!;
      final bool isPostAcceptSlopPastTolerance = _longPressAccepted &&
          postAcceptSlopTolerance != null &&
          _getGlobalDistance(event) > postAcceptSlopTolerance!;

      if (event is PointerMoveEvent &&
          (isPreAcceptSlopPastTolerance || isPostAcceptSlopPastTolerance)) {
        _stopTimer();
        stopTrackingPointer(event.pointer);
        // Gesture ended prematurely, "block" the recognizer
        // for further move and up events from new pointers.
        _state = GestureRecognizerState.defunct;
      }

      handlePointer(event);
    }
    stopTrackingIfPointerNoLongerDown(event);
  }

  void handlePointer(PointerEvent event) {
    if (event is PointerDownEvent) {
      if (_pointerCounter == pointerThreshold) {
        _checkMultiLongPressDown(event);
      }
    } else if (event is PointerMoveEvent) {
      if (_longPressAccepted) {
        if (_pointerCounter == pointerThreshold) {
          _checkMultiLongPressMoveUpdate(event);
        }
      }
    } else if (event is PointerCancelEvent) {
      // _checkMultiLongPressCancel();
      _reset();
    } else if (event is PointerUpEvent) {
      if (_longPressAccepted) {
        if (_pointerCounter == pointerThreshold) {
          _checkMultiLongPressUp(event);
          // "Block" the recognizer for further move and up events
          // from new pointers.
          _state = GestureRecognizerState.defunct;
        }
      }
    }
  }

  void didExceedDeadline(int pointer) {
    if (!_longPressAccepted && _pointerCounter == pointerThreshold) {
      resolve(GestureDisposition.accepted);
      _longPressAccepted = true;
      super.acceptGesture(pointer);
      _checkMultiLongPress();
    }
  }

  double _getGlobalDistance(PointerEvent event) {
    final Offset offset =
        event.position - _initialOffsets[event.pointer]!.global;
    return offset.distance;
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  @override
  void resolve(GestureDisposition disposition) {
    // Send resolve before checking for a possible cancel event, as
    // this can potentially trigger a cancel event themself
    // (and updating the `state` to defunct), which would result in
    // duplicated cancel events.
    super.resolve(disposition);

    if (disposition == GestureDisposition.rejected) {
      if (_longPressAccepted) {
        // Straight up copied, could be incorrect.
        // This can happen if the gesture has been canceled. For example when
        // the buttons have changed.
        _reset();
      } else {
        // Check for possible state to not repeat the cancel after
        // it was rejected even with pointers still on the screen.
        // And also check for minimum pointers to not cancel
        // before a first down call was made.
        if (state == GestureRecognizerState.possible &&
            _pointerCounter >= pointerThreshold) {
          _checkMultiLongPressCancel();
        }
      }
    }
  }

  @override
  void acceptGesture(int pointer) {
    // Winning the arena isn't important here since it may happen from an "empty" arena.
    // Explicitly exceeding the deadline puts the gesture in accepted state.
  }

  @override
  void rejectGesture(int pointer) {
    if (_initialOffsets.containsKey(pointer) &&
        state == GestureRecognizerState.possible) {
      _stopTimer();
      if (!_longPressAccepted && _pointerCounter >= pointerThreshold) {
        // Check for possible state to not repeat the cancel after
        // it was rejected even with pointers still on the screen.
        // And also check for minimum pointers to not cancel
        // before a first down call was made.
        _checkMultiLongPressCancel();
      }
      _state = GestureRecognizerState.defunct;
    }
    super.rejectGesture(pointer);
  }

  @override
  void dispose() {
    _stopTimer();
    _initialOffsets.clear();
    super.dispose();
  }

  void _reset() {
    _longPressAccepted = false;
  }

  void _checkMultiLongPressDown(PointerDownEvent event) {
    if (onMultiLongPressDown != null) {
      invokeCallback<void>(
        "onMultiLongPressDown",
        () => onMultiLongPressDown!(MultiLongPressDownDetails(
          globalPosition: _initialOffsets[event.pointer]!.global,
          localPosition: _initialOffsets[event.pointer]!.local,
          kind: getKindForPointer(event.pointer),
        )),
      );
    }
  }

  void _checkMultiLongPressCancel() {
    if (onMultiLongPressCancel != null) {
      invokeCallback<void>(
          "onMultiLongPressCancel", () => onMultiLongPressCancel!());
    }
  }

  void _checkMultiLongPress() {
    if (onMultiLongPress != null) {
      invokeCallback<void>(
        "onMultiLongPress",
        () => onMultiLongPress!(MultiLongPressDetails(
          globalPositions:
              _initialOffsets.map((key, value) => MapEntry(key, value.global)),
          localPositions:
              _initialOffsets.map((key, value) => MapEntry(key, value.local)),
        )),
      );
    }
  }

  void _checkMultiLongPressMoveUpdate(PointerMoveEvent event) {
    if (onMultiLongPressMoveUpdate != null) {
      invokeCallback<void>(
        "onMultiLongPressMoveUpdate",
        () => onMultiLongPressMoveUpdate!(MultiLongPressMoveUpdateDetails(
          globalPosition: event.position,
          localPosition: event.localPosition,
          offsetFromOrigin:
              event.position - _initialOffsets[event.pointer]!.global,
          localOffsetFromOrigin:
              event.localPosition - _initialOffsets[event.pointer]!.local,
        )),
      );
    }
  }

  void _checkMultiLongPressUp(PointerUpEvent event) {
    if (onMultiLongPressUp != null) {
      invokeCallback<void>(
        "onMultiLongPressUp",
        () => onMultiLongPressUp!(MultiLongPressUpDetails(
          globalPosition: event.position,
          localPosition: event.localPosition,
        )),
      );
    }
  }
}
