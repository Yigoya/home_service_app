import 'package:flutter/material.dart';

class Pagination extends StatelessWidget {
  final int totalPage;
  final int currentPage;
  final Function(int) onPageChanged;

  const Pagination({
    super.key,
    required this.totalPage,
    required this.currentPage,
    required this.onPageChanged,
  });

  List<Widget> _buildPageNumbers() {
    List<Widget> pageNumbers = [];
    for (int i = 1; i <= totalPage; i++) {
      pageNumbers.add(
        GestureDetector(
          onTap: () => onPageChanged(i),
          child: Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
                color: i == currentPage ? Colors.blue : Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(
                '$i',
                style: TextStyle(
                  fontSize: 22,
                  color: i == currentPage ? Colors.white : Colors.black,
                  fontWeight:
                      i == currentPage ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return pageNumbers;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap:
                currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            child: Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: currentPage == 1 ? Colors.grey : Colors.black,
                )),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildPageNumbers(),
              ),
            ),
          ),
          GestureDetector(
            onTap: currentPage < totalPage
                ? () => onPageChanged(currentPage + 1)
                : null,
            child: Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: currentPage == totalPage ? Colors.grey : Colors.black,
                )),
          ),
        ],
      ),
    );
  }
}
