import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../constants.dart';
import '../ui/coffee_image_widget.dart';

final log = Logger('CoffeeAPI');

class CoffeeAPI {
  /// The root directory for the device storage.
  final io.Directory _documentsDirectory;

  /// The directory that will contain the saved image files.
  final io.Directory _savedImagesDirectory;

  /// The directory that will contain the cached image files.
  final io.Directory _cachedImagesDirectory;

  /// Indicates if we have successfully finished calling [init].
  bool _initialized = false;

  /// Indicates if we are actively caching so we don't duplicate work.
  bool _caching = false;

  /// The [http] client we will use to fetch the contents.
  final http.Client _client;

  CoffeeAPI({
    required io.Directory documentsDirectory,
    http.Client? client,
  })  : _documentsDirectory = documentsDirectory,
        _savedImagesDirectory =
            io.Directory(p.join(documentsDirectory.path, 'saved')),
        _cachedImagesDirectory =
            io.Directory(p.join(documentsDirectory.path, 'cached')),
        _client = client ?? http.Client();

  /// This will enusre that there is [kCachedImageCount] items in the cache.
  Future<void> cacheImages([
    int imagesToCache = kCachedImageCount,
    bool breakAfterOne = false,
  ]) async {
    if (_caching) return;
    _caching = true;

    final initalCacheCount = listImagesIn(_cachedImagesDirectory).length;
    log.info('BEFORE: cached image count = $initalCacheCount...');

    while (listImagesIn(_cachedImagesDirectory).length < imagesToCache) {
      String remotePath;
      while (true) {
        try {
          final response = await _client.get(Uri.parse(kCoffeeFetchURL));
          remotePath = jsonDecode(response.body)['file'];

          if (imageIsUnique(remotePath)) break;
        } catch (e) {
          _caching = false;
          return;
        }
      }

      final coffeeImage = CoffeeImage(
        basename: p.basename(remotePath),
        bodyBytes: (await _client.get(Uri.parse(remotePath))).bodyBytes,
      );

      saveImage(coffeeImage, directory: _cachedImagesDirectory);
      if (breakAfterOne) break;
    }
    log.info('AFTER: cached image '
        'count = ${listImagesIn(_cachedImagesDirectory).length}...');
    _caching = false;
  }

  /// Clears the cache directory.
  void clearCache() {
    log.info('Clearing cache...');
    _cachedImagesDirectory.deleteSync(recursive: true);
    _initialized = false;
  }

  /// Removes all of the images saved in [_savedImagesDirectory].
  void clearSaved() {
    log.info('Clearing saved images...');
    _savedImagesDirectory.deleteSync(recursive: true);
    _savedImagesDirectory.createSync();
  }

  /// Remove the image from the specified [directory].
  void deleteImage(CoffeeImage coffeeImage, {io.Directory? directory}) {
    log.info('Deleting image ${coffeeImage.basename} from $directory...');
    final deleteDirectory = directory ?? _cachedImagesDirectory;

    io.File(p.join(deleteDirectory.path, coffeeImage.basename)).deleteSync();
  }

  /// Remove the image specified at the [path].
  void deleteImageByPath(String path) {
    log.info('Deleting image by path $path...');
    io.File(path).deleteSync();
  }

  /// Fetch one image from the remote resource at [kCoffeeFetchURL].
  CoffeeImage? fetchNewImage() {
    if (!_initialized) init();
    log.info('Attemping to fetch new image from cache...');

    var cachedImagesList = listImagesIn(_cachedImagesDirectory);
    if (cachedImagesList.isEmpty) {
      cacheImages();
      return null;
    }

    // Return the first item from the list
    final cachedImagePath = cachedImagesList.first;

    final coffeeImage = CoffeeImage(
      basename: p.basename(cachedImagePath),
      bodyBytes: io.File(
              p.join(_cachedImagesDirectory.path, p.basename(cachedImagePath)))
          .readAsBytesSync(),
    );

    cacheImages();

    return coffeeImage;
  }

  /// Takes the [remotePath] to the resource and checks that the basename is
  /// unique by checking against the [_savedImagesDirectory] and
  /// [_cachedImagesDirectory].
  bool imageIsUnique(String remotePath) =>
      !listImagesIn(_savedImagesDirectory).contains(p.basename(remotePath)) &&
      !listImagesIn(_cachedImagesDirectory).contains(p.basename(remotePath));

  /// Ensure that the directories are found for the cached and saved images.
  ///
  /// [testing] being true indicates we should wait for all caching to be complete.
  Future<void> init({bool testing = false}) async {
    log.info('Initializing...');
    _savedImagesDirectory.createSync();
    _cachedImagesDirectory.createSync();

    final firstRunFile = io.File(p.join(_documentsDirectory.path, 'FIRST_RUN'));
    if (!firstRunFile.existsSync()) {
      // If it is the first time we are running the app, prepopulate
      // 10 images for the user
      for (var i = 0; i < kPrepopulatedImageCount; i++) {
        String remotePath;
        while (true) {
          final response = await _client.get(Uri.parse(kCoffeeFetchURL));
          remotePath = jsonDecode(response.body)['file'];

          if (imageIsUnique(remotePath)) break;
        }

        final coffeeImage = CoffeeImage(
          basename: p.basename(remotePath),
          bodyBytes: (await _client.get(Uri.parse(remotePath))).bodyBytes,
        );

        saveImage(coffeeImage, directory: _savedImagesDirectory);
      }

      // Create the file so that we don't fetch more images on the next
      // start up of the application
      firstRunFile.createSync();
    }

    // We have to await the first call so that there is an image
    // to pull in while the other call downloads them in the background
    if (testing) {
      await cacheImages();
    } else {
      await cacheImages(1, true);
      cacheImages();
    }

    _initialized = true;
  }

  /// Return a list of the saved files from [getApplicationDocumentsDirectory].
  List<String> listImagesIn(io.Directory directory) =>
      directory.listSync().map((item) => p.basename(item.path)).toList();

  /// Lists the contents of the saved directory specifically.
  List<String> listImagesInSavedDirectory() {
    final imagePathsWithDateTime = _savedImagesDirectory
        .listSync()
        .map((e) => {
              'changed': e.statSync().changed,
              'path': e.path,
            })
        .toList();

    // Sort the images so that the new images come first
    imagePathsWithDateTime.sort((a, b) =>
        (b['changed']! as DateTime).compareTo(a['changed']! as DateTime));

    return imagePathsWithDateTime.map((e) => e['path']! as String).toList();
  }

  /// Save an image that was selected from the [CoffeeImageWidget].
  void saveImage(
    CoffeeImage coffeeImage, {
    io.Directory? directory,
    bool userInitiated = false,
  }) {
    final saveDirectory = directory ?? _savedImagesDirectory;
    log.info(
        'Saving image ${coffeeImage.basename} to ${p.basename(saveDirectory.path)}...');

    io.File(p.join(saveDirectory.path, coffeeImage.basename))
        .writeAsBytesSync(coffeeImage.bodyBytes);

    // Remove the image from the cache after saving it
    if (userInitiated) {
      deleteImage(coffeeImage, directory: _cachedImagesDirectory);
    }
  }
}

class CoffeeImage {
  final String basename;

  final Uint8List bodyBytes;
  CoffeeImage({
    required this.basename,
    required this.bodyBytes,
  });

  @override
  String toString() => 'CoffeeImage Instance: $basename';
}
