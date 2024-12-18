import 'package:flutter/material.dart';
import 'package:home_service_app/provider/home_service_provider.dart';
import 'package:home_service_app/screens/home/select_location.dart';
import 'package:provider/provider.dart';

class CategoryServices extends StatelessWidget {
  const CategoryServices({super.key});

  @override
  Widget build(BuildContext context) {
    final services =
        Provider.of<HomeServiceProvider>(context).fiterableByCatagory;
    final category = Provider.of<HomeServiceProvider>(context).selectedCategory;
    final location = Provider.of<HomeServiceProvider>(context).location;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleSpacing: 0, // Added this line to reduce the space
        title: Row(
          children: [
            const Icon(Icons.location_on_rounded,
                color: Colors.green, size: 24),
            const SizedBox(width: 5),
            Text("current location",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.8),
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 5),
            Text('${location['subcity'] ?? ''}, ${location['city'] ?? ''}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Icon(Icons.construction,
                        size: 48, color: Colors.blue[900]),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category!.categoryName,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 106,
                        child: Text(
                          category.description ?? '',
                          style: const TextStyle(
                              fontSize: 20, color: Colors.grey, height: 1.5),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 36),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 9 / 10,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Provider.of<HomeServiceProvider>(context, listen: false)
                            .fetchServiceQuestions(services[index].id);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SelectLocation(service: services[index])));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              [
                                Icons.home_repair_service,
                                Icons.cleaning_services,
                                Icons.electrical_services,
                                Icons.plumbing,
                                Icons.construction,
                                Icons.door_back_door_outlined
                              ].elementAt(index % 6),
                              size: 32,
                              color: Colors.blue[900],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              services[index].name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
