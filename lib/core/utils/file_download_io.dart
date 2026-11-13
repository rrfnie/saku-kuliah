import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> downloadFile(String content, String fileName) async {
  Directory? dir;
  try {
    dir = await getDownloadsDirectory();
  } catch (_) {}
  dir ??= await getApplicationDocumentsDirectory();

  final file = File('${dir.path}/$fileName');
  await file.writeAsString(content);
}

