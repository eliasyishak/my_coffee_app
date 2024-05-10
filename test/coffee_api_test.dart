import 'dart:io' as io;

import 'package:logging/logging.dart';
import 'package:my_coffee_app/src/constants.dart';
import 'package:my_coffee_app/src/data/coffee_api.dart' hide log;
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() async {
  // Configure the logger to print to the console
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) =>
      // ignore: avoid_print
      print('${record.loggerName}: '
          '${record.level.name}: '
          '${record.time} - ${record.message}'));

  late final CoffeeAPI coffeeAPI;
  final io.Directory documentsDirectory = io.Directory(p.join(
    io.Directory.systemTemp.path,
    'coffee_app_testing',
  ));
  final cachedDirectory =
      io.Directory(p.join(documentsDirectory.path, 'cached'));
  final savedDirectory = io.Directory(p.join(documentsDirectory.path, 'saved'));

  final testLogger = Logger('Test logger');

  /// Utility to clear the temp directory contents between runs.
  void clearTempDirectory() {
    testLogger.info('Clearing the temp directory contents...');
    if (documentsDirectory.existsSync()) {
      documentsDirectory.deleteSync(recursive: true);
    }
  }

  setUp(() async {
    clearTempDirectory();
    if (!documentsDirectory.existsSync()) {
      documentsDirectory.createSync();
    }

    coffeeAPI = CoffeeAPI(documentsDirectory: documentsDirectory);
    await coffeeAPI.init(testing: true);
  });

  test('Successfully fetches one image', () {
    final fetchedImage = coffeeAPI.fetchNewImage();
    expect(fetchedImage, isNotNull);
  });

  test('Returns null when cache is empty', () {
    // Clear out the cached directory
    cachedDirectory.deleteSync(recursive: true);
    cachedDirectory.createSync();

    final coffeeImage = coffeeAPI.fetchNewImage();
    expect(coffeeImage, isNull);
  });

  test('Cache has the correct number of images on startup', () {
    expect(cachedDirectory.listSync().length, equals(kCachedImageCount));
  });

  test('Saved directory has the correct number saved', () {
    expect(savedDirectory.listSync().length, equals(kPrepopulatedImageCount));
  });

  test('Saving image works as expected', () {
    final fetchedImage = coffeeAPI.fetchNewImage();

    expect(fetchedImage, isNotNull);
    expect(savedDirectory.listSync().length, equals(kPrepopulatedImageCount));

    coffeeAPI.saveImage(
      fetchedImage!,
      directory: savedDirectory,
      userInitiated: true,
    );

    expect(
        savedDirectory.listSync().length, equals(kPrepopulatedImageCount + 1));

    // Ensure that the image has been removed from the cache as well
    final matches = cachedDirectory
        .listSync()
        .where((element) => p.basename(element.path) == fetchedImage.basename)
        .length;

    expect(matches, equals(0));
  });

  test('Deleting one image works as expected', () {
    // Retrieve the first image in the saved directory and delete it
    final savedImage = savedDirectory.listSync().firstOrNull;

    expect(savedImage, isNotNull);

    coffeeAPI.deleteImageByPath(savedImage!.path);

    expect(
        savedDirectory.listSync().length, equals(kPrepopulatedImageCount - 1));
  });

  test('Deleting one image works as expected using CoffeeImage class', () {
    // Retrieve the first image in the saved directory and delete it
    final savedImage = savedDirectory.listSync().firstOrNull;

    expect(savedImage, isNotNull);

    // Construct the coffee image class
    final constructedCoffeeImage = CoffeeImage(
      basename: p.basename(savedImage!.path),
      bodyBytes: io.File(savedImage.path).readAsBytesSync(),
    );
    coffeeAPI.deleteImage(constructedCoffeeImage, directory: savedDirectory);

    expect(
        savedDirectory.listSync().length, equals(kPrepopulatedImageCount - 1));
  });

  test('Fetching an image will not delete it from the cache', () {
    // We do not want to delete the image when we fetch it because
    // it should remain the same until the user decides to save it
    // or request a new one -- when the user fetches a new image
    // the image will be removed from the cache from the frontend
    final fetchedImage = coffeeAPI.fetchNewImage();

    expect(fetchedImage, isNotNull);

    final matches = cachedDirectory
        .listSync()
        .where((element) => p.basename(element.path) == fetchedImage!.basename)
        .length;
    expect(matches, equals(1));

    final secondFetchedImage = coffeeAPI.fetchNewImage();
    expect(secondFetchedImage, isNotNull);

    expect(fetchedImage!.basename, equals(secondFetchedImage!.basename));
  });

  test('Saves new image in the correct order', () {
    final fetchedImage = coffeeAPI.fetchNewImage();

    expect(fetchedImage, isNotNull);

    coffeeAPI.saveImage(
      fetchedImage!,
      directory: savedDirectory,
      userInitiated: true,
    );

    // The first image in the saved directory should be the image we just saved
    final lastSavedImage = coffeeAPI.listImagesInSavedDirectory().firstOrNull;

    expect(lastSavedImage, isNotNull);
    expect(fetchedImage.basename, equals(p.basename(lastSavedImage!)));
  });

  test('Clearing saved images works as expected', () {
    final savedImageCount = savedDirectory.listSync().length;
    expect(savedImageCount, equals(coffeeAPI.listImagesInSavedDirectory().length));

    coffeeAPI.clearSaved();

    expect(savedDirectory.listSync(), isEmpty);
  });
}
