import 'package:flutter/material.dart';

class ImageDialog extends StatelessWidget {
  final String imagePath;

  const ImageDialog({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Container(
          width: 450,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: ExactAssetImage(imagePath),
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ),
    );
  }
}
