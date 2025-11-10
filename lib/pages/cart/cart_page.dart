import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Корзина')),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          final itemId = index + 1;
          return ListTile(
            title: Text('Товар $itemId'),
            subtitle: Text('Количество: ${index + 1}'),
            trailing: Text('${itemId * 100 * (index + 1)} руб.'),
            onTap: () {
              // Используем HomeRouterDelegate для навигации
              context.goNamed(
                'cart_item',
                pathParameters: {'item_id': (index + 1).toString()},
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Итого: 600 руб.', style: TextStyle(fontSize: 18)),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Оформить заказ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}