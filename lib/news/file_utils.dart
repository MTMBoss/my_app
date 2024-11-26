import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class PdfViewerPage extends StatelessWidget {
  final String filePath;

  const PdfViewerPage({super.key, required this.filePath});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visualizzatore PDF'),
      ),
      body: PDFView(
        filePath: filePath,
      ),
    );
  }
}

Future<void> openDocument(BuildContext context, String url) async {
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
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${url.split('/').last}';
      final file = File(filePath);

      await file.writeAsBytes(response.data);

      if (await file.exists() && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerPage(filePath: file.path),
          ),
        );
      } else {
        // Gestisci il caso in cui il file non esista
      }
    } else {
      // Gestisci il caso in cui il permesso è negato
    }
  } catch (e) {
    // Gestisci gli errori
  }
}

void handleTap(BuildContext context, String? href) async {
  if (href != null) {
    const baseUrl = 'https://conts.it';

    if (href.startsWith('/')) {
      href = '$baseUrl$href';
    }

    if (href.endsWith('.pdf') || href.endsWith('.docx') || href.endsWith('.doc')) {
      await openDocument(context, href);
    } else {
      Uri uri = Uri.parse(href);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }
}
