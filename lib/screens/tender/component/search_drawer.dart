import 'package:flutter/material.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/provider/tender_provider.dart';
import 'package:provider/provider.dart';

class SearchDrawer extends StatefulWidget {
  final TextEditingController searchController;
  final String selectedLocation;
  final List<String> locations;
  final List<Service> filteredSubServices;
  final int serviceId;
  final Function(String) onSearchChanged;
  final Function(String) onLocationChanged;
  final Function(int) onCategorySelected;

  const SearchDrawer({
    Key? key,
    required this.searchController,
    required this.selectedLocation,
    required this.locations,
    required this.filteredSubServices,
    required this.serviceId,
    required this.onSearchChanged,
    required this.onLocationChanged,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  _SearchDrawerState createState() => _SearchDrawerState();
}

class _SearchDrawerState extends State<SearchDrawer> {
  bool _showSubServices = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TenderProvider>(context, listen: false);
    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 24,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: widget.searchController,
                  decoration: InputDecoration(
                    labelText: "Search by name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  onChanged: widget.onSearchChanged,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: widget.selectedLocation,
                  items: widget.locations.map((location) {
                    return DropdownMenuItem(
                        value: location, child: Text(location));
                  }).toList(),
                  onChanged: (value) {
                    widget.onLocationChanged(value!);
                    Navigator.of(context).pop();
                  },
                  decoration: InputDecoration(
                    labelText: "Filter by location",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showSubServices = !_showSubServices;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select Category",
                          style: TextStyle(fontSize: 16),
                        ),
                        Icon(
                          _showSubServices
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                if (_showSubServices)
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: widget.filteredSubServices.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            widget.onCategorySelected(
                                widget.filteredSubServices[index].id);
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              widget.filteredSubServices[index].name,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
