import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const String tableTodo = 'apk_history';
const String columnId = '_id';
const String columnHashKey = 'hash_key';
const String columnPackageName = 'package_name';
const String columnScannedOn = 'scanned';

class ApkHistory {
  int? id;
  String? hashKey;
  String? packageName;
  String? scanned;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnHashKey: hashKey,
      columnPackageName: packageName,
      columnScannedOn: scanned,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  ApkHistory();

  ApkHistory.fromMap(Map<String, Object?> map) {
    id = map[columnId] as int?;
    hashKey = map[columnHashKey] as String?;
    packageName = map[columnPackageName] as String?;
    scanned = map[columnScannedOn] as String?;
  }
}

class ApkHistoryProvider {
  late Database db;

  Future open() async {
    String pathD = await getDatabasesPath();
    String path = join(pathD, '$tableTodo.db');
    db = await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
        CREATE TABLE $tableTodo ( 
          $columnId INTEGER primary key autoincrement, 
          $columnHashKey TEXT not null,
          $columnPackageName TEXT not null,
          $columnScannedOn DATETIME not null)
        ''');
      });
  }

  Future deleteD() async{
    String pathD = await getDatabasesPath();
    String path = join(pathD, '$tableTodo.db');
    deleteDatabase(path);
  }

  Future<ApkHistory> insert(ApkHistory todo) async {
    todo.id = await db.insert(tableTodo, todo.toMap());
    return todo;
  }

  Future insertAll(List<ApkHistory> todo) async {
    var batch = db.batch();
    for (var element in todo) {
      batch.insert(tableTodo, element.toMap());
    }
    await batch.commit();
    return 1;
  }

  Future<ApkHistory?> getApp(String packageName) async {
    List<Map<String, Object?>> maps = await db.query(tableTodo,
        columns: [columnId, columnPackageName, columnHashKey, columnScannedOn],
        where: '$columnPackageName = ?',
        whereArgs: [packageName]);
    if (maps.length > 0) {
      return ApkHistory.fromMap(maps.first);
    }
    return null;
  }

  Future<List?> getChunkedData() async {
    List<Map<String, Object?>> maps = await db.query(tableTodo,
        columns: [columnId, columnPackageName, columnHashKey, columnScannedOn],
    );
    if (maps.length > 0) {
      List<ApkHistory> list = [];
      maps.forEach((element) {
        list.add(ApkHistory.fromMap(element));
      });
      return chunk(list, 20);
    }
    return null;
  }

  Future<int> delete(String package) async {
    return await db.delete(tableTodo, where: '$columnPackageName = ?', whereArgs: [package]);
  }

  Future<int> update(ApkHistory todo) async {
    return await db.update(tableTodo, todo.toMap(),
        where: '$columnPackageName = ?', whereArgs: [todo.packageName]);
  }

  Future close() async => db.close();

  List chunk(List list, int chunkSize) {
    List chunks = [];
    int len = list.length;
    for (var i = 0; i < len; i += chunkSize) {
      int size = i+chunkSize;
      chunks.add(list.sublist(i, size > len ? len : size));
    }
    return chunks;
  }
}