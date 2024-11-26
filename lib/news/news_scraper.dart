import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;

Future<List<Map<String, String>>> scrapeNews() async {
  final List<Map<String, String>> newsDataList = [];
  try {
    final response = await Dio().get('https://conts.it/it/notizie/news/');
    if (response.statusCode == 200) {
      final document = html.parse(response.data);
      final newsCards = document.querySelectorAll('div.news-card');

      for (var card in newsCards) {
        final dateElement = card.querySelector('p.news-date');
        final bodyElement = card.querySelector('p.news-body');
        final pdfLinkElements = card.querySelectorAll('div.doc-file a');
        final List<String> pdfLinks = pdfLinkElements.map((element) => element.attributes['href'] ?? '').toList();

        if (dateElement != null && bodyElement != null) {
          newsDataList.add({
            'date': dateElement.text,
            'body': bodyElement.text,
            'pdfLinks': pdfLinks.join(','), // Salva tutti i link PDF separati da una virgola
            'link': card.querySelector('a')?.attributes['href'] ?? '', // Aggiungi il link alla notizia
          });
        }
      }
    } else {
      newsDataList.add({
        'error': 'Errore nel recupero della pagina: ${response.statusCode}',
      });
    }
  } catch (e) {
    newsDataList.add({
      'error': 'Errore: $e',
    });
  }
  return newsDataList;
}
