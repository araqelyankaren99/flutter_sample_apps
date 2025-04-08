import 'package:flutter_sample_apps/models/faq.dart';

class ExpansionItem {
  ExpansionItem({
    required this.expansionType,
    this.faq,
    this.isClicked = false,
  });

  bool isClicked;
  ExpansionType expansionType;
  FAQ? faq;
}

enum ExpansionType {
  changePhoneNumber,
  language,
  aboutApp,
  email,
  question,
  logOut
}
