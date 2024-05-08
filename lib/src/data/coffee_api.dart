import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants.dart';
import '../ui/coffee_image_widget.dart';

class CoffeeAPI {
  /// The directory that will contain the saved image files.
  io.Directory? _savedImagesDirectory;

  /// The directory that will contain the cached image files.
  io.Directory? _cachedImagesDirectory;

  /// Indicates if we have successfully finished calling [init].
  bool _initialized = false;

  /// Indicates if we are actively caching so we don't duplicate work.
  bool _caching = false;

  CoffeeAPI();

  /// This will enusre that there is [kCachedImageCount] items in the cache.
  Future<void> cacheImages() async {
    if (_caching) return;
    _caching = true;

    final initalCacheCount = listImagesIn(_cachedImagesDirectory!).length;
    print('BEFORE: cached image count = $initalCacheCount...');

    final iterations = kCachedImageCount - initalCacheCount;

    for (var i = 0; i < iterations; i++) {
      String remotePath;
      while (true) {
        final response = await http.get(Uri.parse(kCoffeeFetchURL));
        remotePath = jsonDecode(response.body)['file'];

        if (imageIsUnique(remotePath)) break;
      }

      final coffeeImage = CoffeeImage(
        basename: p.basename(remotePath),
        bodyBytes: (await http.get(Uri.parse(remotePath))).bodyBytes,
      );

      saveImage(coffeeImage, directory: _cachedImagesDirectory!);
    }
    print('AFTER: cached image '
        'count = ${listImagesIn(_cachedImagesDirectory!).length}...');
    _caching = false;
  }

  /// Clears the cache directory.
  void clearCache() {
    print('Clearing cache...');
    _cachedImagesDirectory!.deleteSync(recursive: true);
    _initialized = false;
  }

  void clearSaved() {
    print('Clearing saved images...');
    _savedImagesDirectory!.deleteSync(recursive: true);
    _savedImagesDirectory!.createSync();
  }

  /// Remove the image from the specified [directory].
  void deleteImage(CoffeeImage coffeeImage, {io.Directory? directory}) {
    print('Deleting image ${coffeeImage.basename} from $directory...');
    final deleteDirectory = directory ?? _cachedImagesDirectory!;

    io.File(p.join(deleteDirectory.path, coffeeImage.basename)).deleteSync();
  }

  /// Fetch one image from the remote resource at [kCoffeeFetchURL].
  Future<CoffeeImage> fetchNewImage() async {
    if (!_initialized) await init();
    print('Attemping to fetch new image from cache...');

    var cachedImagesList = listImagesIn(_cachedImagesDirectory!);

    // Return the first item from the list
    final cachedImagePath = cachedImagesList.first;

    final coffeeImage = CoffeeImage(
      basename: p.basename(cachedImagePath),
      bodyBytes: io.File(
              p.join(_cachedImagesDirectory!.path, p.basename(cachedImagePath)))
          .readAsBytesSync(),
    );

    // Remove the image from the cache after displaying it
    deleteImage(coffeeImage, directory: _cachedImagesDirectory!);

    cacheImages();

    return coffeeImage;
  }

  /// Takes the [remotePath] to the resource and checks that the basename is
  /// unique by checking against the [_savedImagesDirectory] and
  /// [_cachedImagesDirectory].
  bool imageIsUnique(String remotePath) =>
      !listImagesIn(_savedImagesDirectory!).contains(p.basename(remotePath)) &&
      !listImagesIn(_cachedImagesDirectory!).contains(p.basename(remotePath));

  /// Ensure that the directories are found for the cached and saved images.
  Future<void> init() async {
    print('Initializing...');
    final documentsDirectory = await getApplicationDocumentsDirectory();
    _savedImagesDirectory ??=
        io.Directory(p.join(documentsDirectory.path, 'saved'));
    _savedImagesDirectory!.createSync();

    _cachedImagesDirectory ??=
        io.Directory(p.join(documentsDirectory.path, 'cached'));
    _cachedImagesDirectory!.createSync();

    await cacheImages();

    _initialized = true;
  }

  /// Return a list of the saved files from [getApplicationDocumentsDirectory].
  List<String> listImagesIn(io.Directory directory) =>
      directory.listSync().map((item) => p.basename(item.path)).toList();

  /// Lists the contents of the saved directory specifically.
  List<String> listImagesInSavedDirectory() =>
      _savedImagesDirectory!.listSync().map((item) => item.path).toList();

  /// Save an image that was selected from the [CoffeeImageWidget].
  void saveImage(
    CoffeeImage coffeeImage, {
    io.Directory? directory,
  }) {
    final saveDirectory = directory ?? _savedImagesDirectory!;
    print('Saving image ${coffeeImage.basename} to $saveDirectory...');

    io.File(p.join(saveDirectory.path, coffeeImage.basename))
        .writeAsBytesSync(coffeeImage.bodyBytes);
  }
}

class CoffeeImage {
  final String basename;

  final Uint8List bodyBytes;
  CoffeeImage({
    required this.basename,
    required this.bodyBytes,
  });
}