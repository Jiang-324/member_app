import 'package:flutter/material.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({ super.key });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final List<Map<String, String>> newsList = [
      {
        'title': 'Community Meetup this Weekend',
        'image': 'https://drive.google.com/uc?export=view&id=1BZBPTqunBVBTaOTAa5tNZuEHkDVbbIt6',
        'body' : 'Join us at the central hall for our annual meetup...'
      },
      {
        'title' : 'New Membership Benefits Announced',
        'image' : 'https://drive.google.com/uc?export=view&id=1DSrFK-dKYU3ATnzmlqWZxTeWTJwMmwcS',
        'body' : 'We’ve partnered with local businesses to offer discounts...'
      },
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Feed'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          final news = newsList[index];
          return _NewsCard(
            title: news['title']!,
            imageUrl: news['image']!,
            body: news['body']!,
          );
        },
      ),
    );
    throw UnimplementedError();
  }
}

class _NewsCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String body;

  const _NewsCard({
    required this.title,
    required this.imageUrl,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
            child: Text(body, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
    // TODO: implement build
    throw UnimplementedError();
  }
}
