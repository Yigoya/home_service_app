import 'package:flutter/material.dart';
import 'package:home_service_app/models/service.dart';
import 'package:home_service_app/provider/tender_provider.dart';
import 'package:home_service_app/screens/tender/component/advance_search.dart';
import 'package:home_service_app/screens/tender/component/tender_card.dart';
import 'package:home_service_app/screens/tender/component/search_drawer.dart';
import 'package:home_service_app/screens/tender/tender_detail_page.dart';
import 'package:provider/provider.dart';

class TenderSearchPage extends StatefulWidget {
  const TenderSearchPage({
    Key? key,
  }) : super(key: key);

  @override
  State<TenderSearchPage> createState() => _TenderSearchPageState();
}

class _TenderSearchPageState extends State<TenderSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  bool _showSearchInterface = false;
  List<Service> _subServices = [];
  List<Service> _filteredSubServices = [];

  @override
  void initState() {
    super.initState();
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
      drawer: TenderSearchDrawer(),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                              left: 16.0, top: 8.0, bottom: 8.0, right: 8.0),
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
                              Icon(Icons.search, color: Colors.grey[600]),
                              const SizedBox(width: 8.0),
                              Text(
                                "name, location or category ",
                                style: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                      Text('${provider.totalTenders} Results ',
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
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
