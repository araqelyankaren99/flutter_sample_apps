import 'package:flutter_sample_apps/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/models/faq.dart';
import 'package:flutter_sample_apps/screens/profile/help/help_page_bloc/help_page_event.dart';
import 'package:flutter_sample_apps/screens/profile/help/help_page_bloc/help_page_state.dart';
import 'package:flutter_sample_apps/screens/profile/shared/expansion_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HelpPageBloc extends Bloc<HelpPageEvent, HelpPageState> {
  HelpPageBloc() : super(HelpPageInitialState());
  final GraphQlRepository _graphQlRepository = GraphQlRepository();

  @override
  Stream<HelpPageState> mapEventToState(
    HelpPageEvent event,
  ) async* {
    if (event is GetFAQsEvent) {
      yield* helpPageGetFAQEventToState(event);
    }
  }

  Stream<HelpPageState> helpPageGetFAQEventToState(GetFAQsEvent event) async* {
    yield FAQsLoadingState();

    try {
      final queryResult = await _graphQlRepository.getFAQ();
      final data = queryResult.data;
      var expansionItems = <ExpansionItem>[];
      if (data != null) {
        expansionItems = (data['getFaqsForDriver'] as List<Map<String,dynamic>>)
            .map<ExpansionItem>(
                (json) => FAQ.fromJson(json).castToExpansionItem(),)
            .toList();
      }

      expansionItems.add(
        ExpansionItem(
          expansionType: ExpansionType.email,
        ),
      );

      yield FAQsLoadedState(expansionItems: expansionItems);
    } catch (e) {
      yield FAQsLoadErrorState(errorMessage: e.toString());
    }
  }
}
