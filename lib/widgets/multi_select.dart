import 'package:flutter/material.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MultiSelectComponent extends StatefulWidget {
  final ValueChanged<List<int>> onSelectionChanged;

  const MultiSelectComponent({super.key, required this.onSelectionChanged});

  @override
  _MultiSelectComponentState createState() => _MultiSelectComponentState();
}

class _MultiSelectComponentState extends State<MultiSelectComponent> {
  List<Service> data = [];

  List<int> selectedIds = [];

  @override
  void initState() {
    super.initState();
    data = Provider.of<HomeServiceProvider>(context, listen: false).services;
  }

  @override
  Widget build(BuildContext context) {
    List<MultiSelectItem<Service>> items =
        data.map((item) => MultiSelectItem<Service>(item, item.name)).toList();

    return MultiSelectDialogField<Service>(
      dialogHeight: 300.h,
      dialogWidth: MediaQuery.of(context).size.width - 40.w,
      items: items,
      title: Text(
        AppLocalizations.of(context)!.selectServices,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
          fontSize: 18.sp,
        ),
      ),
      searchable: true,
      buttonIcon: Icon(Icons.arrow_drop_down_outlined, color: Colors.grey[600]),
      buttonText: Text(AppLocalizations.of(context)!.selectServices,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18.sp, // Use flutter_screenutil for font size
              color: Colors.grey[600]!)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[600]!),
        borderRadius: BorderRadius.circular(
            12.r), // Use flutter_screenutil for border radius
      ),
      onConfirm: (List<Service> selectedItems) {
        selectedIds = selectedItems.map((item) => item.id).toList();
        widget.onSelectionChanged(selectedIds); // Send selected IDs to parent
      },
      chipDisplay: MultiSelectChipDisplay(
        chipColor: Colors.blue.shade50,
        textStyle: TextStyle(color: Colors.black),
        onTap: (Service item) {
          setState(() {
            selectedIds.remove(item.id);
            widget.onSelectionChanged(selectedIds);
          });
        },
      ),
    );
  }
}
