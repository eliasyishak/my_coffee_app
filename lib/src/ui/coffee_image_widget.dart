import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:my_coffee_app/src/constants.dart';

import '../data/coffee_api.dart';
import 'image_dialogue.dart';

class CoffeeImageWidget extends StatefulWidget {
  final CoffeeAPI coffeeAPI;
  final CoffeeImage noInternetImage;

  const CoffeeImageWidget({
    super.key,
    required this.coffeeAPI,
    required this.noInternetImage,
  });

  @override
  State<CoffeeImageWidget> createState() => _CoffeeImageWidgetState();
}

class _CoffeeImageWidgetState extends State<CoffeeImageWidget> {
  @override
  Widget build(BuildContext context) {
    final coffeeImageToDisplay =
        widget.coffeeAPI.fetchNewImage() ?? widget.noInternetImage;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.memory(
                coffeeImageToDisplay.bodyBytes,
                fit: BoxFit.cover,
                height: 450,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (coffeeImageToDisplay.basename != kNoInternetFilename) {
                  widget.coffeeAPI.deleteImage(coffeeImageToDisplay);
                }
                setState(() {});
              },
              child: const Text('New Image'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.coffeeAPI.saveImage(
                  coffeeImageToDisplay,
                  userInitiated: true,
                );
                setState(() {});
              },
              child: const Text('Save Image'),
            ),
            // TextButton(
            //   onPressed: () {
            //     widget.coffeeAPI.clearCache();
            //   },
            //   child: const Text('Clear cache'),
            // ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 25),
                        const Text('Clear All Saved Images?'),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                widget.coffeeAPI.clearSaved();
                                Navigator.pop(context);
                                setState(() {});
                              },
                              child: const Text('Yes'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('No'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: const Text('Clear Saved'),
            ),
            const SizedBox(height: 10),
          ],
        ),
        const SizedBox(height: 10),
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
                      return GestureDetector(
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => Dialog(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const SizedBox(height: 25),
                                  const Text('Delete This Image?'),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          widget.coffeeAPI.deleteImageByPath(widget
                                                  .coffeeAPI
                                                  .listImagesInSavedDirectory()[
                                              index]);
                                          Navigator.pop(context);
                                          setState(() {});
                                        },
                                        child: const Text('Yes'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('No'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (_) => ImageDialog(
                              imagePath: widget.coffeeAPI
                                  .listImagesInSavedDirectory()[index],
                            ),
                          );
                        },
                        child: Image.file(
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          io.File(
                            widget.coffeeAPI
                                .listImagesInSavedDirectory()[index],
                          ),
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
