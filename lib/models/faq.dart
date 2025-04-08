import 'package:flutter_sample_apps/screens/profile/shared/expansion_item.dart';

class FAQ {
  FAQ({required this.id, required this.question, required this.answer});

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
        id: json['id'] as String,
        question: json['question'] as String,
        answer: json['answer'] as String,
    );
  }

  String id;
  String question;
  String answer;

  ExpansionItem castToExpansionItem() {
    return ExpansionItem(faq: this, expansionType: ExpansionType.question);
  }
}
