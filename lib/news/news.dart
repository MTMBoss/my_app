import 'package:flutter/material.dart';
import 'descrizione.dart';
import 'news_scraper.dart';
import 'file_utils.dart';
import 'styles.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  Future<List<Map<String, String>>> fetchNewsData() async {
    return await scrapeNews();
  }

  String convertToEnglishMonth(String date) {
    const months = {
      'Gennaio': 'January',
      'Febbraio': 'February',
      'Marzo': 'March',
      'Aprile': 'April',
      'Maggio': 'May',
      'Giugno': 'June',
      'Luglio': 'July',
      'Agosto': 'August',
      'Settembre': 'September',
      'Ottobre': 'October',
      'Novembre': 'November',
      'Dicembre': 'December',
    };

    months.forEach((italian, english) {
      if (date.contains(italian)) {
        date = date.replaceFirst(italian, english);
      }
    });

    return date;
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('it_IT', null);
    Intl.defaultLocale = 'it_IT';

    return Scaffold(
      appBar: AppBar(
        title: const Text('News', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        toolbarHeight: 56.0,
        backgroundColor: Colors.black87,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: fetchNewsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Errore nel caricamento delle notizie',
                style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nessuna notizia trovata',
                style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          } else {
            final newsDataList = snapshot.data!;

            // Filtra le notizie a partire dal 25 agosto
            final DateTime filterDate = DateTime(2024, 9, 26);
            final DateFormat dateFormat = DateFormat('d MMMM yyyy', 'en');

            final filteredNewsDataList = newsDataList.where((newsData) {
              try {
                final englishDate = convertToEnglishMonth(newsData['date']!);
                final newsDate = dateFormat.parseStrict(englishDate);
                return newsDate.isAfter(filterDate) || newsDate.isAtSameMomentAs(filterDate);
              } catch (e) {
                return false;
              }
            }).toList();

            // Se il filtro rimuove tutte le notizie, mostriamo un messaggio informativo
            if (filteredNewsDataList.isEmpty) {
              return Center(
                child: Text(
                  'Nessuna notizia trovata dopo il 25 agosto',
                  style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: filteredNewsDataList.length,
              itemBuilder: (context, index) {
                final newsData = filteredNewsDataList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DescrizionePage(newsData: newsData),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    decoration: newsCardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: newsCardHeaderDecoration,
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                newsData['date']!,
                                style: newsDateStyle,
                              ),
                              const Icon(Icons.event, color: Colors.white),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            newsData['body']!.trimLeft(),
                            style: newsBodyStyle,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        if (newsData['pdfLink'] != null && newsData['pdfLink']!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                handleTap(context, newsData['pdfLink']);
                              },
                              child: Text(
                                'Apri PDF',
                                style: pdfLinkStyle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      backgroundColor: Colors.black87,
    );
  }
}
