import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/src/models/faq.dart';
import 'package:flutter_sample_apps/src/screens/profile/help/help_page_bloc/help_page_event.dart';
import 'package:flutter_sample_apps/src/screens/profile/help/help_page_bloc/help_page_state.dart';
import 'package:flutter_sample_apps/src/screens/profile/shared/expansion_item.dart';

class HelpPageBloc extends Bloc<HelpPageEvent, HelpPageState> {
  HelpPageBloc() : super(HelpPageInitialState()) {
    on<GetFAQsEvent>(_helpPageGetFAQEventToState);
  }

  final GraphQlRepository _graphQlRepository = GraphQlRepository();

  Future<void> _helpPageGetFAQEventToState(
      GetFAQsEvent event, Emitter<HelpPageState> emit) async {
    emit(FAQsLoadingState());
    try {
      final _queryResult = await _graphQlRepository.getFAQ();

      if (_queryResult.hasException) {
        final exception = _queryResult.exception;

        if (exception != null) {
          final _errorMessage = exception.graphqlErrors.first.toString();
          emit(FAQsLoadErrorState(errorMessage: _errorMessage));
        }

        return;
      }
      final data = _queryResult.data;
      var _expansionItems = <ExpansionItem>[];
      if (data != null) {
        _expansionItems = data['getFaqsForUser']
            .map<ExpansionItem>(
                (json) => FAQ.fromJson(json).castToExpansionItem())
            .toList();
      }

      _expansionItems.add(
        ExpansionItem(
          expansionType: ExpansionType.email,
        ),
      );

      emit(FAQsLoadedState(expansionItems: _expansionItems));
    } catch (e) {
      emit(FAQsLoadErrorState(errorMessage: 'Something went wrong'));
      throw Exception('Something went wrong');
    }
  }
}
