
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:flutter/cupertino.dart';

typedef WorksCreateBloc<T extends WorksCubit<dynamic>> = T Function(
    BuildContext context,
    );

extension WorksBlocProviderExtension on BuildContext {
  /// Performs a lookup using the `BuildContext` to obtain
  /// the nearest ancestor `Cubit` of type [C].
  ///
  /// Calling this method is equivalent to calling:
  ///
  /// ```dart
  /// BlocProvider.of<C>(context)
  /// ```
  C bloc<C extends WorksCubit<Object>>() => WorksBlocProvider.of<C>(this);
}

mixin WorksBlocProviderSingleChildWidget on SingleChildWidget {}

class WorksBlocProvider<T extends WorksCubit<Object>> extends SingleChildStatelessWidget
    with WorksBlocProviderSingleChildWidget {
  /// {@macro bloc_provider}
  WorksBlocProvider({
    Key key,
    @required WorksCreateBloc<T> create,
    Widget child,
    bool lazy,
  }) : this._(
    key: key,
    create: create,
    dispose: (_, bloc) => bloc?.close(),
    child: child,
    lazy: lazy,
  );

  /// Takes a `bloc` and a [child] which will have access to the `bloc` via
  /// `BlocProvider.of(context)`.
  /// When `BlocProvider.value` is used, the `bloc` will not be automatically
  /// closed.
  /// As a result, `BlocProvider.value` should mainly be used for providing
  /// existing `bloc`s to new routes.
  ///
  /// A new `bloc` should not be created in `BlocProvider.value`.
  /// `bloc`s should always be created using the default constructor within
  /// `create`.
  ///
  /// ```dart
  /// BlocProvider.value(
  ///   value: BlocProvider.of<BlocA>(context),
  ///   child: ScreenA(),
  /// );
  /// ```
  WorksBlocProvider.value({
    Key key,
    @required T value,
    Widget child,
  }) : this._(
    key: key,
    create: (_) => value,
    child: child,
  );

  /// Internal constructor responsible for creating the [BlocProvider].
  /// Used by the [BlocProvider] default and value constructors.
  WorksBlocProvider._({
    Key key,
    @required Create<T> create,
    Dispose<T> dispose,
    this.child,
    this.lazy,
  })  : _create = create,
        _dispose = dispose,
        super(key: key, child: child);

  /// [child] and its descendants which will have access to the `bloc`.
  final Widget child;

  /// Whether or not the `bloc` being provided should be lazily created.
  /// Defaults to `true`.
  final bool lazy;

  final Dispose<T> _dispose;

  final Create<T> _create;

  /// Method that allows widgets to access a `cubit` instance as long as their
  /// `BuildContext` contains a [BlocProvider] instance.
  ///
  /// If we want to access an instance of `BlocA` which was provided higher up
  /// in the widget tree we can do so via:
  ///
  /// ```dart
  /// BlocProvider.of<BlocA>(context)
  /// ```
  static T of<T extends WorksCubit<Object>>(BuildContext context) {
    try {
      return Provider.of<T>(context, listen: false);
    } on ProviderNotFoundException catch (e) {
      if (e.valueType != T) rethrow;
      throw FlutterError(
        '''
        BlocProvider.of() called with a context that does not contain a Cubit of type $T.
        No ancestor could be found starting from the context that was passed to BlocProvider.of<$T>().

        This can happen if the context you used comes from a widget above the BlocProvider.

        The context used was: $context
        ''',
      );
    }
  }

  @override
  Widget buildWithChild(BuildContext context, Widget child) {
    return InheritedProvider<T>(
      create: _create,
      dispose: _dispose,
      child: child,
      lazy: lazy,
    );
  }
}


typedef WorksBlocWidgetBuilder<S> = Widget Function(BuildContext context, S state);

/// Signature for the `buildWhen` function which takes the previous `state` and
/// the current `state` and is responsible for returning a [bool] which
/// determines whether to rebuild [BlocBuilder] with the current `state`.
typedef WorksBlocBuilderCondition<S> = bool Function(S previous, S current);


class WorksCubitUnhandledErrorException implements Exception {
  /// {@macro cubit_unhandled_error_exception}
  WorksCubitUnhandledErrorException(this.cubit, this.error, [this.stackTrace]);

  /// The [cubit] in which the unhandled error occurred.
  final WorksCubit cubit;

  /// The unhandled [error] object.
  final Object error;

  /// An optional [stackTrace] which accompanied the error.
  final StackTrace stackTrace;

  @override
  String toString() {
    return 'Unhandled error $error occurred in $cubit.\n'
        '${stackTrace ?? ''}';
  }
}

class WorksBlocObserver {
  /// Called whenever an [event] is `added` to any [bloc] with the given [bloc]
  /// and [event].
  /// The current [BlocObserver].
  static WorksBlocObserver observer = WorksBlocObserver();

  /// Called whenever a [Change] occurs in any [cubit]
  /// A [change] occurs when a new state is emitted.
  /// [onChange] is called before a cubit's state has been updated.
  @protected
  @mustCallSuper
  void onChange(WorksCubit cubit, WorksChange change) {}

  /// Called whenever a transition occurs in any [bloc] with the given [bloc]
  /// and [transition].
  /// A [transition] occurs when a new `event` is `added` and `mapEventToState`
  /// executed.
  /// [onTransition] is called before a [bloc]'s state has been updated.

  /// Called whenever an [error] is thrown in any [Bloc] or [Cubit].
  /// The [stackTrace] argument may be `null` if the state stream received
  /// an error without a [stackTrace].
  @protected
  @mustCallSuper
  void onError(WorksCubit cubit, Object error, StackTrace stackTrace) {}
}

@immutable
class WorksChange<T> {
  /// {@macro change}
  const WorksChange({@required this.currentState, @required this.nextState});

  /// The current [State] at the time of the [Change].
  final T currentState;

  /// The next [State] at the time of the [Change].
  final T nextState;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is WorksChange<T> &&
              runtimeType == other.runtimeType &&
              currentState == other.currentState &&
              nextState == other.nextState;

  @override
  int get hashCode => currentState.hashCode ^ nextState.hashCode;

  @override
  String toString() {
    return 'Change { currentState: $currentState, nextState: $nextState }';
  }
}

class WorksCubit<T> extends Stream<T> {
  /// {@macro cubit}
  WorksCubit(this._model);
  /// The current [state].
  T get model => _model;



  void updateState()
  {
    emit(model);
  }

  WorksBlocObserver get _observer => WorksBlocObserver.observer;

  StreamController<T> _controller;

  T _model;

  /// {@template emit}
  /// Updates the [state] to the provided [state].
  /// [emit] does nothing if the [Cubit] has been closed or if the
  /// [state] being emitted is equal to the current [state].
  ///
  /// To allow for the possibility of notifying listeners of the initial state,
  /// emitting a state which is equal to the initial state is allowed as long
  /// as it is the first thing emitted by the [Cubit].
  /// {@endtemplate}
  @protected
  @visibleForTesting
  void emit(T model) {
    _controller ??= StreamController<T>.broadcast();
    if (_controller.isClosed) return;
    onChange(WorksChange<T>(currentState: this.model, nextState: model));
    _model= model;
    _controller.add(_model);
  }

  /// Notifies the [Cubit] of an [error] which triggers [onError].
  void addError(Object error, [StackTrace stackTrace]) {
    onError(error, stackTrace);
  }




  /// Called whenever a [change] occurs with the given [change].
  /// A [change] occurs when a new `state` is emitted.
  /// [onChange] is called before the `state` of the `cubit` is updated.
  /// [onChange] is a great spot to add logging/analytics for a specific `cubit`.
  ///
  /// **Note: `super.onChange` should always be called last.**
  /// ```dart
  /// @override
  /// void onChange(Change change) {
  ///   // Custom onChange logic goes here
  ///
  ///   // Always call super.onChange with the current change
  ///   super.onChange(change);
  /// }
  /// ```
  ///
  /// See also:
  ///
  /// * [BlocObserver] for observing [Cubit] behavior globally.
  @mustCallSuper
  void onChange(WorksChange<T> change) {
    // ignore: invalid_use_of_protected_member
    _observer.onChange(this, change);
  }

  /// Called whenever an [error] occurs within a [Cubit].
  /// By default all [error]s will be ignored and [Cubit] functionality will be
  /// unaffected.
  /// The [stackTrace] argument may be `null` if the [state] stream received
  /// an error without a [stackTrace].
  /// A great spot to handle errors at the individual [Cubit] level.
  ///
  /// **Note: `super.onError` should always be called last.**
  /// ```dart
  /// @override
  /// void onError(Object error, StackTrace stackTrace) {
  ///   // Custom onError logic goes here
  ///
  ///   // Always call super.onError with the current error and stackTrace
  ///   super.onError(error, stackTrace);
  /// }
  /// ```
  @protected
  @mustCallSuper
  void onError(Object error, StackTrace stackTrace) {
    // ignore: invalid_use_of_protected_member
    _observer.onError(this, error, stackTrace);
    assert(() {
      throw WorksCubitUnhandledErrorException(this, error, stackTrace);
    }());
  }

  /// Adds a subscription to the `Stream<State>`.
  /// Returns a [StreamSubscription] which handles events from
  /// the `Stream<State>` using the provided [onData], [onError] and [onDone]
  /// handlers.
  @override
  StreamSubscription<T> listen(
      void Function(T) onData, {
        Function onError,
        void Function() onDone,
        bool cancelOnError,
      }) {
    _controller ??= StreamController<T>.broadcast();
    return _controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Returns whether the `Stream<State>` is a broadcast stream.
  /// Every [Cubit] is a broadcast stream.
  @override
  bool get isBroadcast => true;

  /// Closes the [Cubit].
  /// When close is called, new states can no longer be emitted.
  @mustCallSuper
  Future<void> close() => _controller?.close();
}

abstract class WorksBlocBuilderBase<C extends WorksCubit<S>, S> extends StatefulWidget {
  /// {@macro bloc_builder_base}
  const WorksBlocBuilderBase({Key key, this.cubit, this.buildWhen})
      : super(key: key);

  /// The [cubit] that the [BlocBuilderBase] will interact with.
  /// If omitted, [BlocBuilderBase] will automatically perform a lookup using
  /// [BlocProvider] and the current `BuildContext`.
  final C cubit;

  /// {@macro bloc_builder_build_when}
  final WorksBlocBuilderCondition<S> buildWhen;

  /// Returns a widget based on the `BuildContext` and current [state].
  Widget build(BuildContext context, S state);

  @override
  State<WorksBlocBuilderBase<C, S>> createState() => WorksBlocBuilderBaseState<C, S>();
}

class WorksBlocBuilder<C extends WorksCubit<S>, S> extends WorksBlocBuilderBase<C, S> {
  /// {@macro bloc_builder}
  const WorksBlocBuilder({
    Key key,
    @required this.builder,
    C cubit,
    WorksBlocBuilderCondition<S> buildWhen,
  })  : assert(builder != null),
        super(key: key, cubit: cubit, buildWhen: buildWhen);

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final WorksBlocWidgetBuilder<S> builder;

  @override
  Widget build(BuildContext context, S state) => builder(context, state);
}
class WorksBlocBuilderBaseState<C extends WorksCubit<S>, S>
    extends State<WorksBlocBuilderBase<C, S>> {
  StreamSubscription<S> _subscription;
  S _previousState;
  S _state;
  C _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit ?? context.bloc<C>();
    _previousState = _cubit?.model;
    _state = _cubit?.model;
    _subscribe();
  }

  @override
  void didUpdateWidget(WorksBlocBuilderBase<C, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldCubit = oldWidget.cubit ?? context.bloc<C>();
    final currentBloc = widget.cubit ?? oldCubit;
    if (oldCubit != currentBloc) {
      if (_subscription != null) {
        _unsubscribe();
        _cubit = widget.cubit ?? context.bloc<C>();
        _previousState = _cubit?.model;
        _state = _cubit?.model;
      }
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) => widget.build(context, _state);

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    if (_cubit != null) {
      _subscription = _cubit.listen((state) {
        if (widget.buildWhen?.call(_previousState, state) ?? true) {
          setState(() {
            _state = state;
          });
        }
        _previousState = state;
      });
    }
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }
}