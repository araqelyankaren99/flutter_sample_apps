import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Магазин')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Товар ${index + 1}'),
            subtitle: Text('Описание товара ${index + 1}'),
            onTap: () {
              context.goNamed(
                'shop_item',
                pathParameters: {'item_id': (index + 1).toString()},
              );
            },
          );
        },
      ),
    );
  }
}