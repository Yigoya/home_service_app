import 'package:flutter/material.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/provider/tender_provider.dart';
import 'package:home_service_app/screens/tender/component/advance_search.dart';
import 'package:home_service_app/screens/tender/component/tender_card.dart';
import 'package:home_service_app/screens/tender/component/search_drawer.dart';
import 'package:home_service_app/screens/tender/tender_detail_page.dart';
import 'package:provider/provider.dart';

class TenderListPage extends StatefulWidget {
  final Service service;
  const TenderListPage({Key? key, required this.service}) : super(key: key);

  @override
  State<TenderListPage> createState() => _TenderListPageState();
}

class _TenderListPageState extends State<TenderListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLocation = 'All Locations';

  String _selectedLanguage = 'en';

  bool _showSearchInterface = false;
  List<Service> _subServices = [];
  List<Service> _filteredSubServices = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<TenderProvider>(context, listen: false)
        .fetchTenders(widget.service.id));
  }

  void _loadSubServices() async {
    final subServices =
        await Provider.of<TenderProvider>(context, listen: false)
            .loadSubServices(widget.service.id);
    setState(() {
      _subServices = subServices;
      _filteredSubServices = subServices;
    });
  }

  void _filterSubServices(String query) {
    setState(() {
      _filteredSubServices = _subServices
          .where((service) =>
              service.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: SearchDrawer(
        searchController: _searchController,
        selectedLocation: _selectedLocation,
        filteredSubServices: _filteredSubServices,
        serviceId: widget.service.id,
        onSearchChanged: (value) {
          Provider.of<TenderProvider>(context, listen: false)
              .searchTenders(value);
        },
        onLocationChanged: (value) {
          setState(() => _selectedLocation = value);
          if (value == "All Locations") {
            Provider.of<TenderProvider>(context, listen: false)
                .fetchTenders(widget.service.id);
          } else {
            Provider.of<TenderProvider>(context, listen: false)
                .filterByLocation(value, widget.service.id);
          }
        },
        onCategorySelected: (id) {
          Provider.of<TenderProvider>(context, listen: false).fetchTenders(id);
        },
      ),
      // drawer: TenderSearchDrawer(),
      body: Consumer<TenderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(child: Text(provider.errorMessage));
          }

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      size: 28,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _loadSubServices();
                    Scaffold.of(context).openDrawer();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    padding: const EdgeInsets.only(
                        left: 16.0, top: 4.0, bottom: 4.0, right: 4.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context)
                            .secondaryHeaderColor
                            .withOpacity(0.7),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Search for ${widget.service.name}",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .secondaryHeaderColor
                                  .withValues(alpha: 100),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).secondaryHeaderColor,
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                            child: Icon(Icons.search,
                                color: Colors.white, size: 20)),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.only(top: 8.0, left: 16, right: 16.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    border: Border(
                        left: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1.5,
                        ),
                        right: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1.5,
                        ),
                        top: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1.5,
                        )),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${provider.totalTenders} ${widget.service.name} ',
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      Text(
                        provider.tenders.isNotEmpty
                            ? "showing ${(provider.page * provider.size) + 1} to ${(provider.page * provider.size) + provider.tenders.length}"
                            : "Nothing to show",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                provider.tenders.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: provider.tenders.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => TenderDetailPage(
                                              tenderId:
                                                  provider.tenders[index].id,
                                            )));
                              },
                              child: TenderCard(
                                tender: provider.tenders[index],
                                isLast: provider.tenders.length - 1 == index,
                              ),
                            );
                          },
                        ),
                      )
                    : Expanded(
                        child: const Center(
                          child: Text("No tenders found",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
