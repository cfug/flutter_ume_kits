# flutter_ume_kit_shared_preferences

基于UME下的shared_preferences插件，可以实时查看修改或删除所有shared_preferences缓存的key的值。

## 接入UME Example

只需把整个flutter_ume_kit_shared_preferences 放入kit中本地导入。修改pubspec如下 即可


```
flutter_ume_kit_shared_preferences:
    path: ../kits/flutter_ume_kit_shared_preferences
    
```

main.dart 新增如下代码，SharedPreferencesInspector模块即可带入UME主模块。

```

..register(SharedPreferencesInspector())

```

## 不接入Example运行

不接入的话，本项目也带有demo main.dart可以直接运行，详情可以看screenshots下录制的视频。 实测支持iOS、安卓、macos。 理论所有shared_preferences插件支持的平台都支持，但是手上没有Linux、Windows平台机器。故而不做保证。