import 'package:flutter/material.dart';

class FeedbacksItemPage extends StatelessWidget {
  final int itemId;

  const FeedbacksItemPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Отзывы о товаре $itemId')),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text('Пользователь ${index + 1}'),
            subtitle: Text(
              'Отзыв о товаре $itemId от пользователя ${index + 1}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                (index % 5) + 1,
                    (i) => const Icon(Icons.star, color: Colors.amber, size: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}