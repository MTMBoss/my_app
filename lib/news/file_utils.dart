import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';

final Logger logger = Logger('FileUtils');

Future<void> openDocument(String url) async {
  try {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      var response = await Dio().get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${url.split('/').last}';
      final file = File(filePath);
      await file.writeAsBytes(response.data);
      await OpenFile.open(file.path);
    } else {
      logger.warning('Permesso di archiviazione negato.');
    }
  } catch (e) {
    logger.severe('Errore durante l\'apertura del documento: $e');
  }
}

void handleTap(String? href) async {
  if (href != null) {
    if (href.endsWith('.pdf') || href.endsWith('.docx') || href.endsWith('.doc')) {
      await openDocument(href);
    } else {
      if (await canLaunchUrlString(href)) {
        await launchUrlString(href);
      }
    }
  }
}
