import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  const StarRating({super.key});

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  int _rating = 0; // Initial rating

  void _onStarTap(int index) {
    setState(() {
      _rating = index; // Update rating to the selected star index
    });
    print(_rating); // Print the rating to the console
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            Icons.star,
            color: index < _rating ? Colors.yellow : Colors.grey,
          ),
          onPressed: () => _onStarTap(index + 1),
        );
      }),
    );
  }
}
