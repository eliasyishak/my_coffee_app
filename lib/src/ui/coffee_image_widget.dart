import 'dart:io' as io;
import 'package:flutter/material.dart';

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
    return FutureBuilder<CoffeeImage>(
      future: widget.coffeeAPI.fetchNewImage(),
      builder: (context, AsyncSnapshot<CoffeeImage> snapshot) {
        return Column(
          children: [
            const SizedBox(
              height: 60,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData
                    ? Image.memory(
                        snapshot.data!.bodyBytes,
                        height: 300,
                        width: 300,
                      )
                    : const SizedBox(
                        height: 300,
                        width: 300,
                        child: Padding(
                          padding: EdgeInsets.all(25),
                          child: CircularProgressIndicator(),
                        ),
                      ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('New image'),
                ),
                TextButton(
                  onPressed: () {
                    widget.coffeeAPI.saveImage(snapshot.data!);
                    setState(() {});
                  },
                  child: const Text('Save image'),
                ),
                TextButton(
                  onPressed: () {
                    widget.coffeeAPI.clearCache();
                  },
                  child: const Text('Clear cache'),
                ),
                TextButton(
                  onPressed: () {
                    widget.coffeeAPI.clearSaved();
                    setState(() {});
                  },
                  child: const Text('Clear saved'),
                )
              ],
            ),
            Row(
              children: [
                Text(widget.coffeeAPI
                    .listImagesInSavedDirectory()
                    .length
                    .toString())
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 250,
                  width: 350,
                  child: GridView.builder(
                    itemCount:
                        widget.coffeeAPI.listImagesInSavedDirectory().length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                    itemBuilder: (context, index) {
                      return Container(
                        // padding: const EdgeInsets.all(8),
                        color: Colors.teal[100],
                        child: Image.file(
                          io.File(
                            widget.coffeeAPI.listImagesInSavedDirectory()[index],
                          ),
                          height: 100,
                          width: 100,
                        ),
                      );
                    },
                  ),
                )
              ],
            )
          ],
        );
      },
    );
  }
}
