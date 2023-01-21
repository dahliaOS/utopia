import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/src/events/base.dart';
import 'package:utopia_wm/src/features/base.dart';
import 'package:utopia_wm/src/layout.dart';
import 'package:uuid/uuid.dart';

import 'registry.dart';

/// Base class for any window inside the WM itself.
///
/// Every property is considered "dry" along with the class instance itself, as such
/// it is possible to have completely constant entries.
///
/// A [WindowEntry] in itself doesn't do anything, it just acts as a generic structure to use
/// to create new windows using the [newInstance] method. This allows you to get an instance
/// of the associated [LiveWindowEntry].
class WindowEntry {
  /// Registry key for the window id. This identifier should be unique across the WM
  /// and as such it is suggested to not define it manually.
  static const WindowPropertyKey<String?> id =
      WindowPropertyKey('window.id', null, readonly: true);

  /// Registry key for the window title.
  static const WindowPropertyKey<String> title =
      WindowPropertyKey('window.title', 'Window');

  /// Registry key for the window icon. It uses flutter ImageProvider so it can
  /// be an asset, a file, a network image and more.
  static const WindowPropertyKey<ImageProvider?> icon =
      WindowPropertyKey('window.icon', null);

  /// Registry key for whether to show the window on the taskbar or not. The only
  /// effect it has on the WM itself is to be a discriminant for returning window
  /// entries on particular getters.
  static const WindowPropertyKey<bool> showOnTaskbar =
      WindowPropertyKey('window.showOnTaskbar', true);

  /// The initial layout configuration of the window. Usually will contain a subclass
  /// of the abstract [LayoutInfo] class. Check its docs for more.
  final LayoutInfo layoutInfo;

  /// A [List] of [WindowFeature]s that make up the capabilities and look of the window.
  /// It is important to note that the order they are in is important as the first feature
  /// wraps every other feature in the list and so on, recursively.
  /// This means that some features could depend on other features to be present before
  /// or after.
  final List<WindowFeature> features;

  /// The initial properties of the window, defined as a [Map] of [WindowPropertyKey]s
  /// and [Object]s.
  final WindowProperties properties;

  /// Create a new [WindowEntry].
  /// It is recommended that any instance is created as const.
  const WindowEntry({
    required this.layoutInfo,
    required this.features,
    required this.properties,
  });

  /// Create a new [LiveWindowEntry] based on this [WindowEntry].
  ///
  /// Allows to pass a [content] param to use as the window content. If null, the
  /// window will just be a frame built using the passed features with the specified layout.
  ///
  /// It is also possible to pass an [eventHandler] to receive and react to window-generated
  /// events, like move, resize, and more.
  ///
  /// [overrideLayout] and [overrideProperties] allow to pass overrides for the layout and
  /// registry info present in the entry fields.
  ///
  /// A window must contain a [WindowEntry.id] key (if absent it'll be generated)
  /// and a [WindowEntry.title] key.
  LiveWindowEntry newInstance({
    Widget? content,
    WindowEventHandler? eventHandler,
    LayoutInfo Function(LayoutInfo info)? overrideLayout,
    WindowProperties overrideProperties = const {},
  }) {
    final WindowProperties completedProperties =
        _completeProperties(properties, overrideProperties);

    final LayoutInfo info = overrideLayout?.call(layoutInfo) ?? layoutInfo;

    return LiveWindowEntry._fromContent(
      content: content ?? const SizedBox.shrink(),
      layoutState: info.createStateInternal(eventHandler),
      features: features,
      eventHandler: eventHandler,
      registry: WindowPropertyRegistry(initialData: completedProperties),
    );
  }

  WindowProperties _completeProperties(
    WindowProperties properties,
    WindowProperties overrideProperties,
  ) {
    final WindowProperties completedProperties = Map.of(properties)
      ..addAll(overrideProperties)
      ..putIfAbsent(id, () => const Uuid().v4());
    assert(
      completedProperties.containsKey(id) &&
          completedProperties.containsKey(title),
    );

    return completedProperties;
  }
}

/// Active representation of a [WindowEntry] instance.
///
/// It can't be directly instantiated but must be created using the [WindowEntry.newInstance]
/// method.
///
/// The [layoutState] field contains a mutable representation of the window layout.
/// It's possible to get the final window view by accessing the [view] getter.
///
/// This view provides access to the window [WindowPropertyRegistry], [LayoutState] and [WindowEventHandler]
/// through different providers.
class LiveWindowEntry {
  /// The raw window content passed from the [WindowEntry.newInstance] method, stored as is.
  /// Usually it is not recommended to access this field directly and it is suggested
  /// to use the [view] getter to get the completed built window.
  final Widget content;

  /// The active state of the window, created by applying the overrides from the
  /// [WindowEntry.newInstance] method to the [WindowEntry] layoutInfo.
  ///
  /// It is recommended to access this field using the exposed provider if possible.
  final LayoutState layoutState;

  /// The [WindowFeature]s of the window, created by applying the overrides from the
  /// [WindowEntry.newInstance] method to the [WindowEntry] features.
  final List<WindowFeature> features;

  /// The mutable property registry of the window, generated by passing the initial
  /// properties created byapplying the overrides from the [WindowEntry.newInstance]
  /// method to the [WindowEntry] properties.
  ///
  /// It is recommended to access this field using the exposed provider if possible.
  final WindowPropertyRegistry registry;

  /// An optional event handler for the window events.
  ///
  /// It is recommended to access this field using the exposed provider if possible.
  final WindowEventHandler? eventHandler;

  /// The texture containing the current visual state of the window.
  final WindowTexture texture;

  final GlobalKey _key = GlobalKey();

  bool _disposed = false;

  Widget? _view;

  /// The window widget created by combining the features with the content.
  ///
  /// You can access this only as long as this [LiveWindowEntry] is not disposed.
  /// It relies on a cached widget that is created automatically at class instantiation
  /// and disposed when the window gets removed from the hierarchy.
  Widget get view {
    if (_disposed || _view == null) {
      throw Exception(
        'This LiveWindowEntry has been disposed and cannot be used anymore: ${registry.info.id}',
      );
    }
    return _view!;
  }

  LiveWindowEntry._fromContent({
    required this.content,
    required this.layoutState,
    required this.features,
    required this.registry,
    this.eventHandler,
  }) : texture = WindowTexture() {
    _view = MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: registry),
        ChangeNotifierProvider.value(value: layoutState),
        ChangeNotifierProvider.value(value: texture),
        Provider.value(value: eventHandler),
      ],
      key: _key,
      child: WindowWrapper(
        features: features,
        content: content,
        texture: texture,
        key: ValueKey(registry.info.id),
      ),
    );
  }

  /// Dispose the created view and invalidate the entry.
  /// It is not recommended to call this method directly as the WM itself will handle
  /// disposal when needed.
  void dispose() {
    _view = null;
    texture.dispose();
    _disposed = true;
  }
}

/// Simple wrapper that builds the window frame around the [content] using the passed [features].
///
/// It should not be used directly, it is expected to be used only by [LiveWindowEntry].
class WindowWrapper extends StatefulWidget {
  final List<WindowFeature> features;
  final WindowTexture? texture;
  final Widget? content;

  const WindowWrapper({
    required this.features,
    this.texture,
    this.content,
    super.key,
  });

  @override
  _WindowWrapperState createState() => _WindowWrapperState();
}

class _WindowWrapperState extends State<WindowWrapper> {
  @override
  void initState() {
    super.initState();

    final WindowPropertyRegistry registry =
        WindowPropertyRegistry.of(context, listen: false);
    for (final WindowFeature feature in widget.features) {
      for (final WindowPropertyKey property in feature.requiredProperties) {
        if (!registry.hasProperty(property)) {
          throw Exception(
            'The required property ${property.name} was not found for the feature ${feature.runtimeType}',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => _buildFeatures(context);

  Widget _buildFeatures(BuildContext context, [int index = 0]) {
    if (index >= widget.features.length) {
      return SizedBox.expand(
        child: widget.texture != null
            ? _WindowRecorder(
                texture: widget.texture!,
                child: widget.content ?? const Placeholder(),
              )
            : widget.content,
      );
    }

    return widget.features[index]
        .build(context, _buildFeatures(context, index + 1));
  }
}

/// Abstract class for an event handler for a [LiveWindowEntry].
///
/// Allows to receive and respond to window generated events by overriding the [onEvent]
/// method or by mixing in the various event helpers provided by the lib, like
/// [ResizeEvents] or [LayoutEvents].
abstract class WindowEventHandler {
  late LiveWindowEntry _entry;

  /// The entry this event handler is associated with.
  LiveWindowEntry get entry => _entry;

  /// Overriding this method allows to receive and react to an event.
  /// In order to react you just return the handler.
  ///
  /// It is required to call `super.onEvent` at the end of the method body to properly
  /// call [onUnhandled].
  @mustCallSuper
  void onEvent(WindowEvent event) {
    onUnhandled(event);
  }

  /// This method can be overridden to react to any event that wasn't handled directly
  /// by the [onEvent] method.
  void onUnhandled(WindowEvent event) {}

  /// Obtain the [WindowEventHandler] associated with the [LiveWindowEntry] if present.
  static WindowEventHandler? maybeOf(BuildContext context) {
    return Provider.of<WindowEventHandler?>(context, listen: false);
  }
}

/* ====== TEXTURES ====== */

/// A [WindowTexture] allows to get a visual stream of the current window
/// state, for example to show a window preview on the taskbar or similar.
/// You can use [WindowTexture.of] to get the nearest texture from a context
/// that derives from a window, else you can use the [texture] getter from
/// [LiveWindowEntry].
class WindowTexture extends ChangeNotifier {
  final ValueNotifier<int> _recordRequestCount = ValueNotifier(0);
  ui.Image? _image;
  bool _disposed = false;

  /// This method will signal the recorder for the window that
  /// it should start recording. This system exists to avoid using resources when not needed.
  ///
  /// Calling this method will increment an internal counter which means the recording will stop
  /// only when each requester will also call [stopRecording].
  void startRecording() {
    _recordRequestCount.value++;
  }

  /// Signals that a requester has stopped recording and the recorder could stop
  /// recording if no other requester is present.
  void stopRecording() {
    _recordRequestCount.value = math.max(_recordRequestCount.value - 1, 0);
  }

  /// The current frame for the window texture.
  /// To get a stream of frames, listen to this provider and get the image using this
  ui.Image? get image => _image;

  /// This method is used internally by the library to signal that a new frame is available.
  /// Refrain from calling this directly unless you know what you're doing.
  void provideFrame(ui.Image frame) {
    if (_recordRequestCount.value <= 0 || _disposed) return;

    _image = frame;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _image = null;
    _recordRequestCount.dispose();
    super.dispose();
  }

  /// Allows to access the currently associated texture for the window.
  /// It is guaranteed to return a proper instance if accessed inside a [context] derived from a window.
  static WindowTexture of(
    BuildContext context, {
    bool listen = true,
  }) {
    return Provider.of<WindowTexture>(context, listen: listen);
  }
}

class _WindowRecorder extends StatefulWidget {
  final WindowTexture texture;
  final Widget child;

  const _WindowRecorder({
    required this.texture,
    required this.child,
  });

  @override
  State<_WindowRecorder> createState() => _WindowRecorderState();
}

class _WindowRecorderState extends State<_WindowRecorder> {
  Timer? timer;
  final GlobalKey key = GlobalKey();

  void _recorderCountListener() {
    final int recordRequestCount = widget.texture._recordRequestCount.value;

    if (recordRequestCount > 0 && timer == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _initTimer());
    } else if (recordRequestCount <= 0) {
      timer?.cancel();
      timer = null;
    }
  }

  @override
  void initState() {
    super.initState();
    widget.texture._recordRequestCount.addListener(_recorderCountListener);
  }

  @override
  void dispose() {
    widget.texture._recordRequestCount.removeListener(_recorderCountListener);
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  void _initTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 10), (timer) async {
      final RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return;

      try {
        final actualImage = boundary.toImageSync();
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          widget.texture.provideFrame(actualImage);
        });
      } catch (e) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(key: key, child: widget.child);
  }
}

/// Widget to display a window from its [WindowTexture].
class WindowSurface extends StatefulWidget {
  /// The [WindowTexture] to listen to and display
  final WindowTexture texture;

  const WindowSurface({
    required this.texture,
    super.key,
  });

  @override
  State<WindowSurface> createState() => _WindowSurfaceState();
}

class _WindowSurfaceState extends State<WindowSurface> {
  late final Widget? content;

  @override
  void initState() {
    super.initState();
    widget.texture.startRecording();
    widget.texture.addListener(update);
  }

  @override
  void dispose() {
    widget.texture.removeListener(update);
    widget.texture.stopRecording();
    super.dispose();
  }

  void update() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TexturePainter(widget.texture.image),
      child: const SizedBox.expand(),
    );
  }
}

class _TexturePainter extends CustomPainter {
  final ui.Image? texture;

  const _TexturePainter(this.texture);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    if (texture == null) return;

    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: texture!,
      fit: BoxFit.contain,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
