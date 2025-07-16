import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryRadioGroup extends StatefulWidget {
  final String name;
  final List<String> options;
  final ValueChanged<List<String>>? onChanged;

  const CategoryRadioGroup({
    super.key,
    required this.name,
    required this.options,
    this.onChanged,
  });

  @override
  _CategoryRadioGroupState createState() => _CategoryRadioGroupState();
}

class _CategoryRadioGroupState extends State<CategoryRadioGroup> {
  late List<String> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = [widget.options.first];
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8,
      children: widget.options.map((option) {
        bool isSelected = _selectedValues.contains(option);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (option == widget.options.first) {
                _selectedValues = [option];
              } else {
                _selectedValues.remove(widget.options.first);
                if (isSelected) {
                  _selectedValues.remove(option);
                  if (_selectedValues.isEmpty) {
                    _selectedValues.add(widget.options.first);
                  }
                } else {
                  _selectedValues.add(option);
                }
              }
            });
            widget.onChanged?.call(_selectedValues);
          },
          child: Container(
            height: 30.h,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(5.r),
              border: Border.all(
                  color: Colors.grey.shade100, width: 1.0),
            ),
            child: Text(
              option,
              style: TextStyle(
                fontSize: 12.sp,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class FormBuilderCategoryRadioGroup extends StatelessWidget {
  final String name;
  final List<String> options;
  final FormFieldValidator<List<String>>? validator;

  const FormBuilderCategoryRadioGroup({
    required this.name,
    required this.options,
    this.validator,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<List<String>>(
      name: name,
      initialValue: [options.first],
      validator: validator,
      builder: (FormFieldState<List<String>> field) {
        return CategoryRadioGroup(
          name: name,
          options: options,
          onChanged: (values) {
            field.didChange(values);
            log('message: $values', name: 'CategoryRadioGroup');
          },
        );
      },
    );
  }
}
