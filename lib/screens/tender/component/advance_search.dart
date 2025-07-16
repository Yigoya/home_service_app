import 'package:flutter/material.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/provider/tender_provider.dart';
import 'package:home_service_app/screens/tender/tender_list_page.dart';
import 'package:home_service_app/screens/tender/tender_search_page.dart';
import 'package:provider/provider.dart';

class TenderSearchDrawer extends StatefulWidget {
  @override
  State<TenderSearchDrawer> createState() => _TenderSearchDrawerState();
}

class _TenderSearchDrawerState extends State<TenderSearchDrawer> {
  bool _showCategories = false;

  @override
  Widget build(BuildContext context) {
    final tenderProvider = Provider.of<TenderProvider>(context);

    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.9,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 60, bottom: 4, right: 20),
            color: Theme.of(context).secondaryHeaderColor,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 16),
                Text(
                  "Search Tenders",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField("Search by Name",
                        tenderProvider.keywordController, Icons.search),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      items: Provider.of<TenderProvider>(context, listen: false)
                          .currentLocations
                          .map((location) {
                        return DropdownMenuItem(
                            value: location, child: Text(location));
                      }).toList(),
                      onChanged: (value) {
                        tenderProvider.setLocation(value!);
                      },
                      decoration: InputDecoration(
                        labelText: "Filter by location",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildServiceDropdown(
                      "Select Category",
                      Provider.of<HomeServiceProvider>(context)
                          .fiterableByCatagory,
                      (val) => tenderProvider.setService(val),
                    ),
                    SizedBox(height: 10),
                    _buildDropdown(
                      "Status",
                      tenderProvider.status,
                      ["OPEN", "CLOSED"],
                      (val) => tenderProvider.setStatus(val),
                    ),
                    SizedBox(height: 10),
                    _buildDateField(
                      context,
                      "Date Posted",
                      tenderProvider.datePosted,
                      (date) => tenderProvider.setDatePosted(date),
                    ),
                    SizedBox(height: 10),
                    _buildDateField(
                      context,
                      "Closing Date",
                      tenderProvider.closingDate,
                      (date) => tenderProvider.setClosingDate(date),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        tenderProvider.advanceTenders();
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TenderSearchPage()));
                      },
                      child: Text("Search"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).secondaryHeaderColor,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool isNumber = false}) {
    return TextField(
      controller: controller, // Use persistent controller

      textDirection: TextDirection.ltr, // Ensure left-to-right typing
      textAlign: TextAlign.start, // Align text to the left
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items.map((String val) {
        return DropdownMenuItem<String>(
          value: val,
          child: Text(val),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildServiceDropdown(
      String label, List<Service> items, Function(Service?) onChanged) {
    return DropdownButtonFormField<Service>(
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      decoration: InputDecoration(
        labelText: label,
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items.map((Service service) {
        return DropdownMenuItem<Service>(
          value: service,
          child: Text(service.name),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField(BuildContext context, String label, DateTime? date,
      Function(DateTime) onDateSelected) {
    return InkWell(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(date != null
            ? "${date.year}-${date.month}-${date.day}"
            : "Select Date"),
      ),
    );
  }
}
