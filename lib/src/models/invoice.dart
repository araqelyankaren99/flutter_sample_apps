class Invoice {
  const Invoice({required this.pdf});

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(pdf: json['pdf']);
  }

  final String pdf;
}
