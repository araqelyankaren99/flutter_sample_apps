import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/auth/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
        // Оставляем кнопку "назад" для возврата на экран входа
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Страница регистрации', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Получаем AuthService через Provider и вызываем login()
                Provider.of<AuthService>(context, listen: false).login();
                // Навигация произойдет автоматически благодаря NavGuard
              },
              child: const Text('Зарегистрироваться'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                context.goNamed('login');
              },
              child: const Text('Назад ко входу'),
            ),
          ],
        ),
      ),
    );
  }
}