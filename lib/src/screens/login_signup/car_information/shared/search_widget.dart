import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/src/style.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget(
      {required this.controller, this.onChanged, this.onPressed});
  final TextEditingController controller;
  final Function(String)? onChanged;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: athensGrayColor,
            borderRadius: BorderRadius.all(
              Radius.circular(10 * constants.rw(context)),
            )),
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 20 * constants.rw(context)),
        child: Theme(
            data: Theme.of(context).copyWith(
              primaryColor: Colors.grey,
            ),
            child: TextField(
              onChanged: onChanged,
              controller: controller,
              style: getStyle(
                  color: blackColor, weight: FontWeight.w500, fontSize: 16),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 35 * constants.rh(context),
                    color: Colors.grey,
                  ),
                  suffixIcon: IconButton(
                    onPressed: onPressed,
                    icon: const Icon(Icons.clear, color: Colors.grey),
                  )),
            )));
  }
}
