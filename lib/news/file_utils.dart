import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';

final Logger logger = Logger('FileUtils');

// Base URL del sito per convertire i link relativi in link assoluti
const String baseUrl = 'https://conts.it';

Future<void> openDocument(String url) async {
  try {
    logger.info('Tentativo di aprire il file: $url');

    // Controllo dei permessi di archiviazione
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      logger.info('Richiesta permesso di archiviazione...');
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      logger.info('Permesso di archiviazione concesso.');

      // Scarica il file con redirezioni abilitate
      var response = await Dio().get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );

      // Ottieni la directory temporanea
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${url.split('/').last}';
      final file = File(filePath);

      // Salva il file
      logger.info('Salvataggio del file in: $filePath');
      await file.writeAsBytes(response.data);

      // Verifica se il file esiste e aprilo
      if (await file.exists()) {
        logger.info('File salvato correttamente: ${file.path}');
        await OpenFile.open(file.path);
      } else {
        logger.warning('Il file non è stato salvato correttamente.');
      }
    } else {
      logger.warning('Permesso di archiviazione negato.');
    }
  } catch (e) {
    logger.severe('Errore durante l\'apertura del documento: $e');
  }
}

void handleTap(String? href) async {
  if (href != null) {
    // Converti i link relativi in link assoluti
    if (href.startsWith('/')) {
      href = '$baseUrl$href';
      logger.info('Link relativo convertito in assoluto: $href');
    }

    logger.info('Gestione del link: $href');

    // Controlla se il link è un file scaricabile
    if (href.endsWith('.pdf') || href.endsWith('.docx') || href.endsWith('.doc')) {
      await openDocument(href);
    } else {
      // Apri i link normali nel browser
      if (await canLaunchUrlString(href)) {
        logger.info('Apertura del link nel browser: $href');
        await launchUrlString(href);
      } else {
        logger.warning('Impossibile aprire il link: $href');
      }
    }
  }
}
