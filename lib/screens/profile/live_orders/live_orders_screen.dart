import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/main.dart';
import 'package:flutter_sample_apps/middlewares/overlay/overlay_call.dart';
import 'package:flutter_sample_apps/models/driver.dart';
import 'package:flutter_sample_apps/models/order.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/sign_up_bloc/sign_up_bloc.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/sign_up_bloc/sign_up_event.dart';
import 'package:flutter_sample_apps/screens/order_view/bloc/order_view_bloc.dart';
import 'package:flutter_sample_apps/screens/order_view/order_view.dart';
import 'package:flutter_sample_apps/screens/profile/live_orders/live_orders_bloc/live_orders_bloc.dart';
import 'package:flutter_sample_apps/screens/profile/live_orders/live_orders_bloc/live_orders_event.dart';
import 'package:flutter_sample_apps/screens/profile/live_orders/live_orders_bloc/live_orders_state.dart';
import 'package:flutter_sample_apps/screens/profile/live_orders/network_bloc/network_bloc.dart';
import 'package:flutter_sample_apps/screens/profile/live_orders/network_bloc/network_event.dart';
import 'package:flutter_sample_apps/screens/profile/live_orders/network_bloc/network_state.dart';
import 'package:flutter_sample_apps/screens/profile/profile_drawer/profile_drawer.dart';
import 'package:flutter_sample_apps/screens/profile/profile_drawer/profile_drawer_bloc/profile_informaiton_event.dart';
import 'package:flutter_sample_apps/screens/profile/profile_drawer/profile_drawer_bloc/profile_information_bloc.dart';
import 'package:flutter_sample_apps/screens/profile/shared/animated_custom_scroll_view.dart';
import 'package:flutter_sample_apps/screens/profile/shared/no_order_message.dart';
import 'package:flutter_sample_apps/shared/alert_widget.dart';
import 'package:flutter_sample_apps/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/shared/connectivity/connection.dart';
import 'package:flutter_sample_apps/shared/loading_widget.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class LiveOrdersScreen extends StatefulWidget {
  const LiveOrdersScreen({required this.order});
  final Order? order;
  @override
  _LiveOrdersScreenState createState() => _LiveOrdersScreenState();
}

class _LiveOrdersScreenState extends State<LiveOrdersScreen>
    // with FirebaseNotificationMixin
{
  List<Order> get _unconfirmedOrders => _liveOrdersBloc.unconfirmedOrders;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late NetworkBloc _networkBloc;
  final _overlayCall = OverlayCall();
  final _profileInformationBloc = ProfileInformationBloc();
  late LiveOrdersBloc _liveOrdersBloc;
  late OrderViewBloc _ordersBloc;
  bool _showLoading = true;

  @override
  void initState() {
    super.initState();
    // listenPushNotifications(
    //     () => _liveOrdersBloc.add(const GetUnconfirmedOrdersEvent()),);

    _checkConnectionAndInitFirebase();
    _initCurrentOrder();
  }

  @override
  Widget build(BuildContext context) {
    return _render();
  }

  Widget _render() {
    return WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SafeArea(
                bottom: false,
                child: MultiBlocProvider(
                    providers: [
                      BlocProvider<LiveOrdersBloc>(create: (context) {
                        _liveOrdersBloc = LiveOrdersBloc();
                        return _liveOrdersBloc;
                      },),
                      BlocProvider.value(value: _ordersBloc),
                      BlocProvider.value(value: _networkBloc)
                    ],
                    child: MultiBlocListener(
                      listeners: [
                        BlocListener<NetworkBloc, NetworkState>(
                          listener: _networkListener,
                        ),
                        BlocListener<OrderViewBloc, OrderViewState>(
                            listener: _orderViewListener,),
                        BlocListener<LiveOrdersBloc, LiveOrdersState>(
                            listener: _liveOrderViewListener,),
                      ],
                      child: BlocBuilder<LiveOrdersBloc, LiveOrdersState>(
                          builder: (context, state) {
                        return LoadingWidget(
                            isLoading: _showLoading, child: _renderPage(),);
                      },),
                    ),),
              ),
              _renderPageView(),
            ],
          ),
        ),);
  }

  Widget _renderPageView() {
    return IgnorePointer(
      ignoring: _currentPage == 0,
      child: PageView(
        allowImplicitScrolling: true,
        reverse: true,
        onPageChanged: _onPageChange,
        physics: const ClampingScrollPhysics(),
        controller: _pageController,
        children: [
          Container(
            color: Colors.transparent,
          ),
          BlocProvider.value(
              value: _profileInformationBloc,
              child: ProfileDrawer(
                callBackFunction: _profileDrawerCallbackFuntion,
                fromOrdersScreen: true,
              ),),
        ],
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
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 10 * constants.rh(context)),
                child: _renderList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _renderBackgroundColor() {
    return Container(
      color: blackHazeColor,
    );
  }

  Widget _renderAppBar() {
    return AppBarWidget(
      backgroundColor: Colors.white,
      titleText: 'Live Orders',
      titleStyle: getStyle(weight: FontWeight.w500, fontSize: 20),
      prefixWidget: _renderMenuBtn(),
    );
  }

  Widget _renderMenuBtn() {
    return InkWell(
      onTap: _onPressedMenu,
      child: Container(
        margin: const EdgeInsets.all(10),
        child: SvgPicture.asset(
          'assets/images/menu.svg',
          height: 40,
        ),
      ),
    );
  }

  Widget _renderList() {
    return Stack(
      children: [_renderNoOrderMessage(), _renderSliverList()],
    );
  }

  Widget _renderNoOrderMessage() {
    return NoOrderMessage(
        opacity: _unconfirmedOrders.isEmpty && !_showLoading ? 1.0 : 0.0,);
  }

  Widget _renderSliverList() {
    return AnimatedCustomScrollView(
      unconfirmedOrders: _unconfirmedOrders,
      onRefresh: () async {
        Connection.checker(context,
            onDone: () => _liveOrdersBloc
              ..add(const UpdateDriverLocationEvent())
              ..add(const GetUnconfirmedOrdersEvent()),);
      },
    );
  }

  // This method opens ProfileDrawer
  void _onPressedMenu() {
    _pageController.animateToPage(1,
        duration: const Duration(milliseconds: 300), curve: Curves.linear,);
  }

  /// This function changes _currentPage value to page, that is opened
  void _onPageChange(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  /// This function returns to MapView screen and is called when user taps outside of ProfileDrawer body
  void _profileDrawerCallbackFuntion() {
    _pageController.animateToPage(0,
        duration: const Duration(milliseconds: 300), curve: Curves.linear,);
  }

  /// This function navigate to order screen
  void _navigateOrderView(Order order, {bool alreadyConfirmed = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BlocProvider.value(
                value: _ordersBloc,
                child: OrderView(
                  order: order,
                  alreadyConfirmed: alreadyConfirmed,
                ),
              ),),
    );
  }

  void _initCurrentOrder() {
    if (widget.order != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => {
            if (widget.order?.state != OrderStatus.unconfirmed &&
                widget.order?.state != OrderStatus.canceled)
              {_navigateOrderView(widget.order!, alreadyConfirmed: true)}
          },);
    }
  }

  void _checkConnectionAndInitFirebase() {
    _networkBloc = NetworkBloc()..add(CheckConnection());
    _ordersBloc = OrderViewBloc();
  }

  void _orderViewListener(BuildContext context, state) {
    if (state is CannotConfirmOrderState) {
      _liveOrdersBloc
        ..add(const UpdateDriverLocationEvent())
        ..add(const GetUnconfirmedOrdersEvent());
      if (state.errorMessagePreferance == ErrorMessagePreferance.failed) {
        AlertWidget().showOrderClosed(context);
      }
    }
    if (state is OrderConfirmFailedState) {
      AlertWidget().showMessage(context, 'Something went wrong!');
      _liveOrdersBloc.add(const GetUnconfirmedOrdersEvent());
    }
    if (state is FirebaseTokenUpdateFailed) {
      AlertWidget().showMessage(context, state.message);
    }
  }

  void _liveOrderViewListener(BuildContext context, state) {
    if (state is UnconfirmedOrdersLoadErrorState || state is NoInternetState) {
      _showLoading = false;
    }
    if (state is LocationUpdateFailedState) {
      AlertWidget().showMessage(context, state.message);
    }
  }

  void _networkListener(BuildContext context, state) {
    if (state is ConnectionFailure) {
      _overlayCall.showEntry(context: context);
      _liveOrdersBloc.add(NoInternetEvent());
    }
    if (state is ConnectionSuccess) {
      _ordersBloc.add(const InitFCMEvent());
      _liveOrdersBloc
        ..add(const UpdateDriverLocationEvent())
        ..add(const GetUnconfirmedOrdersEvent());
      if (!state.firstCheck) {
        _overlayCall.remove();
        final homeScreen = state.homeScreen;
        final homeScreenType = homeScreen.keys.first;
        final driver = homeScreen.values.first;
        if (!homeScreen.containsKey(HomeScreenType.liveOrders)) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => BlocProvider<SignUpBloc>(
                    create: (context) {
                      final signUpBloc = SignUpBloc();
                      final hasDriver = driver == null;
                      if (!hasDriver) {
                        signUpBloc.add(ListenDriverActivationEvent());
                      }
                      return signUpBloc;
                    },
                    child: homeScreenType.getHomeScreen(
                        driver as Driver?, null,),),),
            (Route route) => false,
          );
        } else {
          _profileInformationBloc.add(const GetProfileInformationEvent());
        }
      }
    }
  }
}
