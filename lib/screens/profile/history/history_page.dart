import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/models/order.dart';
import 'package:flutter_sample_apps/screens/profile/history/history_page_bloc/history_page_bloc.dart';
import 'package:flutter_sample_apps/screens/profile/history/history_page_bloc/history_page_event.dart';
import 'package:flutter_sample_apps/screens/profile/history/history_page_bloc/histroy_page_state.dart';
import 'package:flutter_sample_apps/screens/profile/order/order_card_widget.dart';
import 'package:flutter_sample_apps/shared/alert_widget.dart';
import 'package:flutter_sample_apps/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/shared/loading_widget.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late HistoryPageBloc _historyPageBloc;
  List<Order> get _ordersList => _historyPageBloc.ordersList;

  @override
  void dispose() {
    _historyPageBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HistoryPageBloc>(
      create: (context) {
        _historyPageBloc = HistoryPageBloc();
        _historyPageBloc.add(const GetUserOrdersEvent());
        return _historyPageBloc;
      },
      child: BlocListener<HistoryPageBloc, HistoryPageState>(
        listener: _listener,
        child: BlocBuilder<HistoryPageBloc, HistoryPageState>(
          builder: (context, state) {
            return LoadingWidget(
              isLoading: state is UserOrdersLoadingState,
              child: _render(),
            );
          },
        ),
      ),
    );
  }

  void _listener(BuildContext context, state) {
    if (state is UserOrdersLoadErrorState) {
      AlertWidget().showMessage(context, state.errorMessage);
    }
  }

  Widget _render() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: _renderPage(),
      ),
    );
  }

  Widget _renderPage() {
    return Stack(
      children: [
        _renderBackgroundColor(),
        Column(
          children: [
            _renderAppBar(),
            _renderTotalEarnings(),
            Expanded(
              child: _renderList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _renderTotalEarnings() {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 20 * constants.rh(context),
      ),
      child: Column(
        children: [
          _renderAmount(),
          _renderTotalEarningsText(),
          _renderLast30DaysText(),
        ],
      ),
    );
  }

  Container _renderAmount() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10 * constants.rh(context)),
      child: Text(
        '\$' + '${_historyPageBloc.amount}',
        style: getStyle(
            fontSize: 28, weight: FontWeight.w700, color: azureRadianceColor,),
      ),
    );
  }

  Container _renderTotalEarningsText() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5 * constants.rh(context)),
      child: Text(
        'Total Earnings',
        style: getStyle(
          fontSize: 18,
          weight: FontWeight.w500,
          color: cloudBurstColor,
        ),
      ),
    );
  }

  Container _renderLast30DaysText() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5 * constants.rh(context)),
      child: Text(
        'Last 30 days',
        style: getStyle(
          fontSize: 16,
          weight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _renderBackgroundColor() {
    return Container(
      color: blackHazeColor,
    );
  }

  Widget _renderList() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10 * constants.rh(context),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _ordersList.length,
        itemBuilder: (context, index) {
          return _renderOrder(index);
        },
      ),
    );
  }

  Widget _renderOrder(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _orderDate(index),
        _renderOrdersTime(index),
        _renderOrderCard(index),
      ],
    );
  }

  Widget _orderDate(int index) {
    return (_showDate(index)) ? _renderOrdersDate(index) : Container();
  }

  Widget _renderOrderCard(int index) {
    return OrderCardWidget(
      order: _ordersList[index],
      orderInfos: const [
        OrderInfo.road,
      ],
      showViewAndAmountAndKmText: true,
      margin: EdgeInsets.fromLTRB(20 * constants.rw(context), 0,
          20 * constants.rw(context), 10 * constants.rh(context),),
      padding: EdgeInsets.all(20 * constants.rw(context)),
    );
  }

  Widget _renderOrdersDate(int index) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        20 * constants.rw(context),
        5 * constants.rh(context),
        0,
        5 * constants.rh(context),
      ),
      child: Text(
        DateFormat.yMMMd().format(_ordersList[index].dueDate),
        style: getStyle(
          color: cadetBlueColor,
        ),
      ),
    );
  }

  Widget _renderOrdersTime(int index) {
    return Container(
      margin: EdgeInsets.fromLTRB(20 * constants.rw(context),
          5 * constants.rh(context), 0, 10 * constants.rh(context),),
      child: Text(DateFormat('kk:mm').format(_ordersList[index].dueDate),
          style: getStyle(color: azureRadianceColor, weight: FontWeight.w500),),
    );
  }

  Widget _renderAppBar() {
    return AppBarWidget(
      backgroundColor: Colors.white,
      titleText: 'Request History',
      titleStyle: getStyle(weight: FontWeight.w500, fontSize: 20),
      prefixWidget: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: const Icon(
          Icons.arrow_back_sharp,
          color: Colors.black,
        ),
      ),
    );
  }

//returns true if order's date is different(is made on different day) from previous order's date
  bool _showDate(int index) {
    return index == 0 ||
        (index > 0 &&
            (_ordersList[index].dueDate.day.compareTo(
                    _historyPageBloc.ordersList[index - 1].dueDate.day,) !=
                0));
  }
}
