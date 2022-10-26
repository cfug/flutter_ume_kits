import 'package:flutter/material.dart';
import 'package:flutter_ume/flutter_ume.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_preferences_inspector.dart';

void main() {
  runApp(UMEWidget(child: MyApp()));
  PluginManager.instance..register(SharedPreferencesInspector());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UME Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'SharedreferencesKit Demo Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title = "SharedreferencesKit Demo Page"}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      if (value.getBool("TestBoolKey") == null) {
        value.setBool("TestBoolKey", true);
      }
      if (value.getDouble("TestDoubleKey") == null) {
        value.setDouble("TestDoubleKey", 1.0);
      }
      if (value.getString("TestStringKey") == null) {
        value.setString("TestStringKey", "Hello Word!");
      }
      if (value.getInt("TestIntKey") == null) {
        value.setInt("TestIntKey", 520);
      }
      if (value.getStringList("TestStringList") == null) {
        value.setStringList("TestStringList", ["t1", "t2", "t3"]);
      }
    });
    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Hello World! I\' m SharedreferencesKit!',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
