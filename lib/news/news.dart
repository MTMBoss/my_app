import 'package:flutter/material.dart';
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
              padding: const EdgeInsets.all(16.0),
              itemCount: newsDataList.length,
              itemBuilder: (context, index) {
                final newsData = newsDataList[index];
                return Card(
                  color: Colors.grey[850],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Data: ${newsData['date']}', style: TextStyle(color: Colors.white)),
                        SizedBox(height: 8),
                        Text('Body: ${newsData['body']}', style: TextStyle(color: Colors.white)),
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
