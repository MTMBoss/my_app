import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;
import 'package:html/dom.dart' as dom;
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logger/logger.dart';
import 'styles.dart'; // Importa gli stili

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

      if (textBlockElement != null) {
        final hasHighlightedText = textBlockElement.querySelector('a') != null;

        // Se ci sono parole evidenziate, mostriamo solo il corpo della descrizione
        if (hasHighlightedText) {
          return textBlockElement.innerHtml;
        }

        // Documenti senza parole evidenziate, includendo i link ai PDF
        final pdfLinkElements = document.querySelectorAll('div.doc-file a');
        List<String> pdfLinks = pdfLinkElements.map((e) {
          final href = e.attributes['href'];
          final text = e.text.trim();
          return '<a href="$href">$text</a>';
        }).toList();

        return '${textBlockElement.innerHtml}\n\n${pdfLinks.join('\n')}';
      } else {
        return 'Descrizione non trovata';
      }
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
    final String? link = newsData['link'];
    if (link == null || link.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Descrizione', style: pageTitleStyle), // Usa lo stile definito in styles.dart
          backgroundColor: Colors.black87,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: Text(
            'Link non disponibile',
            style: errorMessageStyle, // Usa lo stile definito in styles.dart
          ),
        ),
        backgroundColor: Colors.black87,
      );
    }

    final newsUrl = 'https://conts.it$link'; // Assicurati che l'URL sia completo

    return Scaffold(
      appBar: AppBar(
        title: Text('Descrizione', style: pageTitleStyle), // Usa lo stile definito in styles.dart
        backgroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<String>(
        future: fetchNewsDescription(newsUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Nessun documento disponibile senza parole evidenziate',
                style: errorMessageStyle, // Usa lo stile definito in styles.dart
              ),
            );
          } else {
            // Il resto del codice per mostrare la descrizione e i PDF
            final document = html.parse(snapshot.data!);
            final paragraphs = document.querySelectorAll('p');
            final pdfLinks = document.querySelectorAll('a');
            List<InlineSpan> textSpans = [];

            for (var paragraph in paragraphs) {
              for (var node in paragraph.nodes) {
                if (node is dom.Element && node.localName == 'a') {
                  final href = node.attributes['href'];
                  textSpans.add(
                    TextSpan(
                      text: node.text,
                      style: linkTextStyle, // Usa lo stile definito in styles.dart
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

            List<Widget> pdfWidgets = [];
            for (var link in pdfLinks) {
              final href = link.attributes['href'];
              pdfWidgets.add(
                Card(
                  color: Colors.black54, // Colore del card per la dark mode
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                    title: Text(link.text.trimLeft(), style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      handleTap(href?.startsWith('/') == true
                          ? 'https://conts.it$href'
                          : href);
                    },
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: newsBodyStyle, // Usa lo stile definito in styles.dart
                              children: textSpans,
                            ),
                          ),
                          const SizedBox(height: 0), // Spazio tra il testo e i PDF
                          ...pdfWidgets, // Aggiungi i widget dei PDF alla fine del testo
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      backgroundColor: Colors.black87,
    );
  }
}
