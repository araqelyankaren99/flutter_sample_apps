import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/src/style.dart';

class TxtFieldWithIcon extends StatelessWidget {
  const TxtFieldWithIcon(
      {super.key, required this.label,
      this.prefixWidgets,
      this.padding = EdgeInsets.zero,
      this.enabled = true,
      this.controller,
      this.focus,
      this.onChange,
      this.validator,
      this.labelColor = spunPearlColor,
      this.txtType,
      this.action,
      this.onFieldSubmitted,
      this.onEditingComplete,
      this.onTap,
      this.scrollPadding = const EdgeInsets.all(20.0),
      this.initialValue});
  final Widget? prefixWidgets;
  final String label;
  final EdgeInsets padding;
  final bool enabled;
  final TextEditingController? controller;
  final FocusNode? focus;
  final Function(String)? onChange;
  final String? Function(String?)? validator;
  final Color? labelColor;
  final TextInputType? txtType;
  final EdgeInsets scrollPadding;
  final TextInputAction? action;
  final Function(String)? onFieldSubmitted;
  final void Function()? onEditingComplete;
  final Function()? onTap;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 35 * constants.rw(context)),
      padding: padding,
      child: Row(
        children: [
          Container(
              margin: EdgeInsets.only(top: 20 * constants.rh(context)),
              width: 20 * constants.rw(context),
              height: 22 * constants.rh(context),
              child: prefixWidgets),
          SizedBox(
            width: 20 * constants.rw(context),
          ),
          Flexible(
            child: TextFormField(
              initialValue: initialValue,
              readOnly: !enabled,
              onChanged: onChange,
              focusNode: focus,
              scrollPadding: scrollPadding,
              keyboardType: txtType,
              controller: controller,
              validator: validator,
              textInputAction: action,
              onTap: onTap,
              onFieldSubmitted: onFieldSubmitted,
              onEditingComplete: onEditingComplete,
              style: getStyle(
                  color: codGrayColor, fontSize: 18, weight: FontWeight.w500),
              decoration: InputDecoration(
                errorStyle: getStyle(
                  color: Colors.red,
                ),
                labelStyle: getStyle(
                    color: labelColor, fontSize: 16, weight: FontWeight.w500),
                labelText: label,
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: spunPearlColor)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: codGrayColor)),
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
