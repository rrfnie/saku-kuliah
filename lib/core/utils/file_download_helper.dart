import 'file_download_stub.dart'
    if (dart.library.html) 'file_download_web.dart'
    if (dart.library.io) 'file_download_io.dart';

/// Helper universal untuk mengunduh berkas (Web & Mobile / Desktop)
class FileDownloadHelper {
  FileDownloadHelper._();

  static Future<void> download(String content, String fileName) async {
    await downloadFile(content, fileName);
  }
}

