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
    return FutureBuilder<CoffeeImage>(
      future: widget.coffeeAPI.fetchNewImage(),
      builder: (context, AsyncSnapshot<CoffeeImage> snapshot) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData
                    ? Expanded(
                      child: Image.memory(
                          fit: BoxFit.cover,
                          snapshot.data!.bodyBytes,
                          height: 450,
                        ),
                    )
                    : const SizedBox(
                        height: 400,
                        width: 400,
                        child: Padding(
                          padding: EdgeInsets.all(25),
                          child: CircularProgressIndicator(),
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
                    widget.coffeeAPI.saveImage(snapshot.data!);
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
                        itemCount: widget.coffeeAPI
                            .listImagesInSavedDirectory()
                            .length,
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
                              widget.coffeeAPI
                                  .listImagesInSavedDirectory()[index],
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
      },
    );
  }
}
