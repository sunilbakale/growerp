import 'package:flutter/material.dart';

class DropDownField extends StatefulWidget {
  final List<String> items;

  DropDownField({Key key, @required this.items}) : super(key: key);

  @override
  _DropDownFieldState createState() => _DropDownFieldState(items);
}

class _DropDownFieldState extends State<DropDownField> {
  final List<String> items;
  String _selectedLocation;

  _DropDownFieldState(this.items);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 500, height: 60,
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(
              color: Colors.grey, style: BorderStyle.solid, width: 0.80),
        ),
        child: DropdownButton(
          underline: SizedBox(), // remove underline
          hint: Text('Currency'),
          value: _selectedLocation,
          items: items
              .map((value) => DropdownMenuItem(
                    child: Text(value),
                    value: value,
                  ))
              .toList(),
          onChanged: (String newValue) {
            setState(() {
              _selectedLocation = newValue;
            });
          },
          isExpanded: false,
        ),
      ),
    );
  }
}
