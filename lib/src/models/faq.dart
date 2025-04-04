
import 'package:flutter_sample_apps/src/screens/profile/shared/expansion_item.dart';

class FAQ {
  const FAQ({required this.id, required this.question, required this.answer});

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
        id: json['id'], question: json['question'], answer: json['answer']);
  }

  final String id;
  final String question;
  final String answer;

  ExpansionItem castToExpansionItem() {
    return ExpansionItem(faq: this, expansionType: ExpansionType.question);
  }
}
