import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои заказы')),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Заказ #${10000 + index}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Статус: ${index % 3 == 0
                            ? 'Доставлен'
                            : index % 3 == 1
                            ? 'В пути'
                            : 'Обработка'}',
                        style: TextStyle(
                          color:
                          index % 3 == 0
                              ? Colors.green
                              : index % 3 == 1
                              ? Colors.blue
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Дата: ${DateTime.now().subtract(Duration(days: index * 3)).toString().substring(0, 10)}',
                  ),
                  const SizedBox(height: 8),
                  Text('Сумма: ${(index + 1) * 500} руб.'),
                  const SizedBox(height: 8),
                  Text('Товаров: ${index + 2}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}