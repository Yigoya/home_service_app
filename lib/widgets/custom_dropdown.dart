import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDropdown extends StatelessWidget {
  final List<String> items;
  final String hint;
  final ValueChanged<String?> onChanged;
  final String? selectedValue;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[600]!),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: InputDecoration.collapsed(hintText: ''),
            hint: Text(hint),
            value: selectedValue,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            selectedItemBuilder: (BuildContext context) {
              return items.map<Widget>((String item) {
                return Text(item);
              }).toList();
            },
            itemHeight: null,
            menuMaxHeight: 260.h,
          ),
        ),
      ),
    );
  }
}
