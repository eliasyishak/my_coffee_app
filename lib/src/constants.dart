/// The URL to fetch the random coffee image.
const kCoffeeFetchURL = 'https://coffee.alexflipnote.dev/random.json';

/// How many images to keep in cache.
///
/// These cachced images will be saved on disk and will get
/// pulled from, once we have depleted all of the cached images,
/// we will pull again and save in the cached location.
const kCachedImageCount = 3;
