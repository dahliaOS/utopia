import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/src/features/base.dart';
import 'package:uuid/uuid.dart';

import 'registry.dart';

class WindowEntry {
  static const WindowPropertyKey<String?> id =
      WindowPropertyKey('window.id', null, readonly: true);
  static const WindowPropertyKey<String> title =
      WindowPropertyKey('window.title', 'Window');
  static const WindowPropertyKey<ImageProvider?> icon =
      WindowPropertyKey('window.icon', null);
  static const WindowPropertyKey<bool> alwaysOnTop =
      WindowPropertyKey('window.alwaysOnTop', false);
  static const WindowPropertyKey<AlwaysOnTopMode> alwaysOnTopMode =
      WindowPropertyKey('window.alwaysOnTopMode', AlwaysOnTopMode.window);
  static const WindowPropertyKey<bool> showOnTaskbar =
      WindowPropertyKey('window.showOnTaskbar', true);

  final List<WindowFeature> features;
  final Map<WindowPropertyKey, Object?> properties;

  const WindowEntry({
    required this.features,
    required this.properties,
  });

  LiveWindowEntry newInstance([
    Widget? content,
    Map<WindowPropertyKey, Object?> overrideProperties = const {},
  ]) {
    final Map<WindowPropertyKey, Object?> completedProperties =
        Map.of(properties)
          ..addAll(overrideProperties)
          ..putIfAbsent(id, () => Uuid().v4());
    assert(completedProperties.containsKey(id) &&
        completedProperties.containsKey(title) &&
        completedProperties.containsKey(icon));

    return LiveWindowEntry._(
      content: content ?? SizedBox(),
      features: features,
      registry: WindowPropertyRegistry(initialData: completedProperties),
    );
  }
}

enum AlwaysOnTopMode {
  /// A window set to be in this mode will be on top only of other windows and
  /// behind system overlays
  window,

  /// If a window is set to be a system overlay then it will be over anything
  /// else, without ever getting something else on top if not other system overlays
  systemOverlay,
}

class LiveWindowEntry {
  final Widget content;
  final List<WindowFeature> features;
  final WindowPropertyRegistry registry;
  bool _disposed = false;

  Widget? _view;
  Widget get view {
    if (_disposed || _view == null) {
      throw Exception(
        'This LiveWindowEntry has been disposed and cannot be used anymore: ${registry.info.id}',
      );
    }
    return _view!;
  }

  LiveWindowEntry._({
    required this.content,
    required this.features,
    required this.registry,
  }) : _view = ChangeNotifierProvider.value(
          value: registry,
          child: WindowWrapper(
            features: features,
            content: content,
            key: ValueKey(registry.info.id),
          ),
          key: GlobalKey(),
        );

  void dispose() {
    _view = null;
    _disposed = true;
    print('LIVE WINDOW ENTRY ${registry.info.id} DISPOSED');
  }
}

class WindowWrapper extends StatefulWidget {
  final List<WindowFeature> features;
  final Widget content;

  const WindowWrapper({
    required this.features,
    required this.content,
    Key? key,
  }) : super(key: key);

  @override
  _WindowWrapperState createState() => _WindowWrapperState();
}

class _WindowWrapperState extends State<WindowWrapper> {
  @override
  void initState() {
    super.initState();
    final registry = WindowPropertyRegistry.of(context, listen: false);
    for (WindowFeature feature in widget.features) {
      for (WindowPropertyKey property in feature.requiredProperties) {
        bool contains = registry.hasProperty(property);
        if (!contains) {
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
    if (index >= widget.features.length)
      return SizedBox.expand(child: widget.content);

    return widget.features[index]
        .build(context, _buildFeatures(context, index + 1));
  }
}
