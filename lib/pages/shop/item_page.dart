import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ItemPage extends StatelessWidget {
  final int itemId;
  final String prefix;

  const ItemPage({super.key, required this.itemId, required this.prefix});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Товар $itemId')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Информация о товаре $itemId',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text('Цена: ${itemId * 100} руб.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.goNamed(
                  '${prefix}_feedback',
                  pathParameters: {'item_id': itemId.toString()},
                );
              },
              child: const Text('Отзывы'),
            ),
          ],
        ),
      ),
    );
  }
}