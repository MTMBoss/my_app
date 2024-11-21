import 'package:flutter/material.dart';
import 'descrizione.dart';
import 'news_scraper.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  Future<List<Map<String, String>>> fetchNewsData() async {
    return await scrapeNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, String>>>(
        future: fetchNewsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore nel caricamento delle notizie', style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nessuna notizia trovata', style: TextStyle(color: Colors.white)));
          } else {
            final newsDataList = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: newsDataList.length,
              itemBuilder: (context, index) {
                final newsData = newsDataList[index];
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
                    margin: EdgeInsets.symmetric(vertical: 4.0), // Reduce vertical margin
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      border: Border.all(color: Colors.grey[850]!), // Same color as background
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.grey[700],
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            newsData['date']!,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.zero, // Remove padding completely
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                newsData['body']!.trimLeft(), // Trim leading spaces
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.left,
                              ),
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
    );
  }
}
