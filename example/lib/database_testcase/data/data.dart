import 'package:database_kit/database_kit.dart';
import 'package:hive/hive.dart';
part 'data.g.dart';

@HiveType(typeId: 0)
class Person with UMEHiveData {
  Person({required this.age, required this.name});
  @HiveField(0)
  String name;
  @HiveField(1)
  int age;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'name': name, 'age': age};
  }
}

@HiveType(typeId: 1)
class Table with UMEHiveData {
  Table({required this.age, required this.name});
  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'name': name, 'age': age};
  }
}

@HiveType(typeId: 2)
class Test with UMEHiveData {
  Test({required this.age, required this.name});
  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'name': name, 'age': age};
  }
}
