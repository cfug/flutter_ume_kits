## flutter_ume_kit_slow_animation

慢速动画调节插件

## 使用方式

``` yaml
dependencies:
  flutter_ume_kit_slow_animation:
```

``` dart
void main() {
  PluginManager.instance
    ..register(const SlowAnimation());

  runApp(const UMEWidget(child: MyApp()));
}
```