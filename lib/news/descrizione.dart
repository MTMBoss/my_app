import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;
import 'package:html/dom.dart' as dom;
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logger/logger.dart';

// Crea un'istanza del logger
final logger = Logger();

class DescrizionePage extends StatelessWidget {
  final Map<String, String> newsData;

  const DescrizionePage({super.key, required this.newsData});

  Future<String> fetchNewsDescription(String url) async {
    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final document = html.parse(response.data);
        final textBlockElement = document.querySelector('div.text-block');
        return textBlockElement?.innerHtml ?? 'Descrizione non trovata';
      } else {
        return 'Errore nel recupero della pagina: ${response.statusCode}';
      }
    } catch (e) {
      logger.d('Errore durante il recupero della descrizione: $e');
      return 'Errore: $e';
    }
  }

  void handleTap(String? url) async {
    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      logger.d('URL non valido: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsUrl = 'https://conts.it${newsData['link']}'; // Assicurati che l'URL sia completo

    return Scaffold(
      body: FutureBuilder<String>(
        future: fetchNewsDescription(newsUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text(
                'Errore nel caricamento della descrizione',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            final document = html.parse(snapshot.data!);
            final paragraphs = document.querySelectorAll('p');
            List<InlineSpan> textSpans = [];

            for (var paragraph in paragraphs) {
              for (var node in paragraph.nodes) {
                if (node is dom.Element && node.localName == 'a') {
                  final href = node.attributes['href'];
                  textSpans.add(
                    TextSpan(
                      text: node.text,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => handleTap(href?.startsWith('/') == true
                            ? 'https://conts.it$href'
                            : href),
                    ),
                  );
                } else if (node is dom.Text) {
                  textSpans.add(TextSpan(text: node.text));
                }
              }
              textSpans.add(const TextSpan(text: '\n\n'));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Indietro'),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                          children: textSpans,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
