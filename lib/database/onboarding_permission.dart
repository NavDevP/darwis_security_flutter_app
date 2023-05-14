import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const String tableName = 'onboarding_permission';
const String columnId = '_id';
const String columnOnBoarding = 'onboarding_done';
const String columnAlertPermission = 'system_alert_permission';
const String columnCallPermission = 'call_sms_permission';

class OnBoardingPermission {
  int? id;
  int onBoarding = 0;
  int alertPermission = 0;
  int callPermission = 0;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnOnBoarding: onBoarding,
      columnAlertPermission: alertPermission,
      columnCallPermission: callPermission,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  OnBoardingPermission();

  OnBoardingPermission.fromMap(Map<String, Object?> map) {
    id = map[columnId] as int?;
    onBoarding = map[columnOnBoarding] != null ? (map[columnOnBoarding] as int) : 0;
    alertPermission = map[columnAlertPermission] != null ? (map[columnAlertPermission] as int) : 0;
    callPermission = map[columnCallPermission] != null ? (map[columnCallPermission] as int) : 0;
  }
}

class OnBoardingPermissionProvider {
  late Database db;

  Future open() async {
    String pathD = await getDatabasesPath();
    String path = join(pathD, '$tableName.db');
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
        CREATE TABLE $tableName ( 
          $columnId INTEGER primary key autoincrement, 
          $columnOnBoarding INTEGER not null,
          $columnAlertPermission INTEGER not null,
          $columnCallPermission INTEGER not null)
        ''');
        });
  }

  Future deleteD() async{
    String pathD = await getDatabasesPath();
    String path = join(pathD, '$tableName.db');
    deleteDatabase(path);
  }

  Future<OnBoardingPermission> insert(OnBoardingPermission todo) async {
    todo.id = await db.insert(tableName, todo.toMap());
    return todo;
  }

  Future<OnBoardingPermission?> getData() async {
    List<Map<String, Object?>> maps = await db.query(tableName,
        columns: [columnId, columnOnBoarding, columnAlertPermission, columnCallPermission]
    );
    if (maps.length > 0) {
      return OnBoardingPermission.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(String package) async {
    return await db.delete(tableName, where: '$columnId = ?', whereArgs: [1]);
  }

  Future<int> update(OnBoardingPermission todo) async {
    return await db.update(tableName, todo.toMap(),
        where: '$columnId = ?', whereArgs: [1]);
  }

  Future close() async => db.close();
}