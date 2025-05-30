import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _notes = [
  'Note 1',
  'Note 2',
  'Note 3',
  'Note 4',
  'Note 5',
  'Note 6',
];

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.separated(
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_notes[index]),
              onTap: () {
                context.go('/notes/detail/$index');
              },
            );
          },
          separatorBuilder: (context, index) {
            return const Divider();
          },
          itemCount: _notes.length),
    );
  }
}