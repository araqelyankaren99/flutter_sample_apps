import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/screens/profile/order/order_card_widget_bloc.dart/order_card_event.dart';
import 'package:flutter_sample_apps/src/screens/profile/order/order_card_widget_bloc.dart/order_card_state.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class OrderCardBloc extends Bloc<OrderCardEvent, OrderCardState> {
  OrderCardBloc() : super(OrderCardInitialState()) {
    on<InvoicePdfEvent>(_invoicePdfEventToState);
  }

  Future<void> _invoicePdfEventToState(
      InvoicePdfEvent event, Emitter<OrderCardState> emit) async {
    emit(OrderCardLoadingState());

    File file;
    final invoiceUrl = event.invoiceUrl;
    try {
      if (invoiceUrl == null) {
        emit(InvoicePdfLoadError());
        emit(OrderCardInitialState());
        return;
      }
      final data = await http.get(Uri.parse(invoiceUrl));

      final bytes = data.bodyBytes;
      final dir = await getApplicationDocumentsDirectory();
      file = _fileFromDir(dir);
      await file.writeAsBytes(bytes);
    } catch (e) {
      emit(InvoicePdfLoadError());
      emit(OrderCardInitialState());
      throw Exception('Error loading pdf file!');
    }
    OpenFile.open(file.path);
    emit(InvoicePdfLoaded());
    emit(OrderCardInitialState());
  }

  /// Creates file from directory
  File _fileFromDir(Directory dir) {
    const fileName = InvoicePreferences.fileName;
    return File('${dir.path}/$fileName.pdf');
  }
}

class InvoicePreferences {
  static const fileName = 'invoice';
}
