import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:utopia_wm/src/features/base.dart';
import 'package:utopia_wm/src/layout.dart';
import 'package:uuid/uuid.dart';

import 'registry.dart';

class WindowEntry {
  static const WindowPropertyKey<String?> id =
      WindowPropertyKey('window.id', null, readonly: true);
  static const WindowPropertyKey<String> title =
      WindowPropertyKey('window.title', 'Window');
  static const WindowPropertyKey<ImageProvider?> icon =
      WindowPropertyKey('window.icon', null);
  static const WindowPropertyKey<bool> showOnTaskbar =
      WindowPropertyKey('window.showOnTaskbar', true);

  final LayoutInfo layoutInfo;
  final List<WindowFeature> features;
  final Map<WindowPropertyKey, Object?> properties;

  const WindowEntry({
    required this.layoutInfo,
    required this.features,
    required this.properties,
  });

  LiveWindowEntry newInstance({
    Widget? content,
    LayoutInfo Function(LayoutInfo info)? overrideLayout,
    Map<WindowPropertyKey, Object?> overrideProperties = const {},
  }) {
    final Map<WindowPropertyKey, Object?> completedProperties =
        Map.of(properties)
          ..addAll(overrideProperties)
          ..putIfAbsent(id, () => const Uuid().v4());
    assert(completedProperties.containsKey(id) &&
        completedProperties.containsKey(title) &&
        completedProperties.containsKey(icon));

    final LayoutInfo info = overrideLayout?.call(layoutInfo) ?? layoutInfo;

    return LiveWindowEntry._(
      content: content ?? const SizedBox(),
      layoutState: info.createStateInternal(),
      features: features,
      registry: WindowPropertyRegistry(initialData: completedProperties),
    );
  }
}

class LiveWindowEntry {
  final Widget content;
  final LayoutState layoutState;
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
    required this.layoutState,
    required this.features,
    required this.registry,
  }) : _view = MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: registry),
            ChangeNotifierProvider.value(value: layoutState),
          ],
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
    if (index >= widget.features.length) {
      return SizedBox.expand(child: widget.content);
    }

    return widget.features[index]
        .build(context, _buildFeatures(context, index + 1));
  }
}
