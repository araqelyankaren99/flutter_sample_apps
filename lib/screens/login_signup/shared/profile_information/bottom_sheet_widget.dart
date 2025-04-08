import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter_sample_apps/screens/login_signup/profile_information/user_info_bloc/user_info_bloc.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/user_info_bloc/user_info_event.dart';
import 'package:flutter_sample_apps/screens/login_signup/shared/profile_information/btm_sheet_title_widget.dart';
import 'package:flutter_sample_apps/shared/next_button.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget(
      {required this.list, required this.selectedItem, this.bottomSheetHeight,});
  final double? bottomSheetHeight;
  final List list;
  final String selectedItem;

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  late List<ListItem> itemsList;

  late String _selectedItem;
  TextEditingController controller = TextEditingController();
  UserInfoBloc get _userInfoBloc => BlocProvider.of<UserInfoBloc>(context);

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  /// Initiliaze variables, and set is choosed
  void _initialize() {
    _selectedItem = widget.selectedItem;
    itemsList = _toListItem(widget.list);
    _setIsSelectedElement(itemsList);
  }

  @override
  Widget build(BuildContext context) {
    return _renderBody();
  }

  Widget _renderBody() {
    return Container(
      height: widget.bottomSheetHeight,
      decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20 * constants.rw(context)),
            topRight: Radius.circular(20 * constants.rw(context)),
          ),),
      child: _renderColumn(),
    );
  }

  Widget _renderColumn() {
    final list = _fillter(controller.text);

    return Column(children: [
      _renderBottomSheetTopWidget(list: list),
      _renderListView(list: list),
      _renderNextButton(list: list)
    ],);
  }

  Widget _renderBottomSheetTopWidget({required List<ListItem> list}) {
    return BtmSheetTitleWidget(
      controller: controller,
      onChanged: (val) {
        _setIsSelectedElement(itemsList);
        setState(() {});
      },
      onPressed: () {
        _setIsSelectedElement(itemsList);
        setState(() {
          controller.clear();
        });
      },
    );
  }

  Widget _renderListView({required List<ListItem> list}) {
    return Expanded(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                  onTap: () {
                    final isSelected = list[index].isSelected;
                    _setUnselectedToList(list);
                    list[index].isSelected = !isSelected;
                    if (list[index].isSelected) {
                      _selectedItem = list[index].data;
                    } else {
                      _selectedItem = '';
                    }
                    setState(() {});
                  },
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 20 * constants.rw(context),),
                  trailing: Visibility(
                      visible: list[index].isSelected,
                      child: const Icon(
                        Icons.done,
                        color: azureRadianceColor,
                      ),),
                  title: Text(
                    list[index].data,
                    style: getStyle(
                        color: blackColor,
                        weight: FontWeight.w500,
                        fontSize: 18,),
                  ),);
            },),);
  }

  Widget _renderNextButton({required List<ListItem> list}) {
    return SafeArea(
        top: false,
        child: Container(
            margin: EdgeInsets.only(bottom: 10 * constants.rh(context)),
            alignment: Alignment.bottomCenter,
            child: Visibility(
                visible: MediaQuery.of(context).viewInsets.bottom == 0,
                child: NextButton(
                  isActive: _isSelected(),
                  borderColor: whiteColor,
                  onPress: () {
                    if (_selectedItem.isNotEmpty) {
                      _userInfoBloc
                          .add(ChoosingUserCityEvent(city: _selectedItem));
                    }
                    Navigator.pop(context);
                  },
                  text: 'Save',
                  textColor: _isSelected() ? whiteColor : blackColor,
                ),),),);
  }

  List<ListItem> _toListItem(Iterable list) {
    return list.map(( e) => ListItem(e as String)).toList();
  }

  List<ListItem> _fillter(String searchigName) {
    return itemsList
        .where((searching) =>
            searching.data.toLowerCase().contains(searchigName.toLowerCase()),)
        .toList();
  }

  bool _isSelected() {
    if (_selectedItem != '') {
      return true;
    }
    return false;
  }

//set selected element in incoming list
  void _setIsSelectedElement(List<ListItem> list) {
    if (_isSelected()) {
      for (final item in list) {
        if (item.data == _selectedItem) {
          _setUnselectedToList(list);
          item.isSelected = true;
        }
      }
    }
  }

//All element in list make unselected
  void _setUnselectedToList(List<ListItem> list) {
    for (final item in list) {
      item.isSelected = false;
    }
  }
}

class ListItem {
  ListItem(this.data);
  bool isSelected = false; //Selection property to show done icon or not
  String data; //Data of the user

}
