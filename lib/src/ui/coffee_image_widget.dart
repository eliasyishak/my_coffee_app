import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../data/coffee_api.dart';

class CoffeeImageWidget extends StatefulWidget {
  const CoffeeImageWidget({
    super.key,
    required this.coffeeAPI,
  });

  final CoffeeAPI coffeeAPI;

  @override
  State<CoffeeImageWidget> createState() => _CoffeeImageWidgetState();
}

class _CoffeeImageWidgetState extends State<CoffeeImageWidget> {
  @override
  Widget build(BuildContext context) {
    final coffeeImage = widget.coffeeAPI.fetchNewImage();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.memory(
                coffeeImage.bodyBytes,
                fit: BoxFit.cover,
                height: 450,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                setState(() {});
              },
              child: const Text('New image'),
            ),
            TextButton(
              onPressed: () {
                widget.coffeeAPI.saveImage(coffeeImage);
                setState(() {});
              },
              child: const Text('Save image'),
            ),
            // TextButton(
            //   onPressed: () {
            //     widget.coffeeAPI.clearCache();
            //   },
            //   child: const Text('Clear cache'),
            // ),
            TextButton(
              onPressed: () {
                widget.coffeeAPI.clearSaved();
                setState(() {});
              },
              child: const Text('Clear saved'),
            )
          ],
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/coffee-bean-pattern.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    itemCount:
                        widget.coffeeAPI.listImagesInSavedDirectory().length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemBuilder: (context, index) {
                      return Image.file(
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        io.File(
                          widget.coffeeAPI.listImagesInSavedDirectory()[index],
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
