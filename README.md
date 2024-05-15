# Coffee by Elias

Welcome fellow Coffee enthusiasts! I hope this app can give you some fun coffee
images to view while waiting for a flight, your doctor's waiting room, and even
while waiting for your coffee!

[![Watch the video](public/Video%20screen.png)](https://github.com/eliasyishak/my_coffee_app/assets/42216813/6e27319d-b32f-42a4-b2a8-d3b2a5dc813b)


# Usage Instructions

### Running Locally
To run this app locally, ensure you have Flutter and Dart downloaded by first
following the [Flutter setup directions](https://docs.flutter.dev/get-started/install).

Once you have downloaded Flutter and confirm that everything is set, run `flutter doctor`
in your terminal to ensure you have setup your workstation properly. Once that is
complete, open a terminal in the root directory of this directory and run `flutter run`.
Note, this has been tested to run on both iOS and Android only, desktop and web
are not the intended targets for this app.

### Viewing Images
To view your next image, you simply open the app and a new image will be shown
to you on startup. If you are not a fan of this image, you can click the first
button labeled `New Image` to cycle through a new image.

### Saving Images
If you enjoy the current image being shown to you and you would like to save it,
simply click the `Save Image` button and it will be saved in your local storage
below. After saving the image, a new image will be cycled through.

### Viewing Saved Images
If you would like to view a previously saved image in more detail, you can scroll
in the window below the buttons to an image and tap on it. It will open the image
in a popup window in more detail for your viewing pleasure. Once you are done viewing
the image, you can tap anywhere on the screen and you will be back to the home page.

[![Watch the video](public/Viewing%20screen.png)](https://github.com/eliasyishak/my_coffee_app/assets/42216813/1467e6df-770e-4cef-aca9-f2dd81d46851)

### Deleting Saved Images
If for some reason, you no longer enjoy the coffee image you downloaded, you can delete
it from your local storage by long pressing the image you wish to delete. You will be
prompted with a pop up that will ask if you are sure you want to delete it.

### Deleting All Saved Images
On the off chance you want a complete reset, you can simply press the `Clear Saved`
button and that will allow you to delete all of your images from local storage.

# Technical Details
### On Start-Up
When the app starts up for the first time, the following happen:

1. The application finds the storage location for the app.
2. It will then create two directories at that location; `cached` and `saved`. The
`cached` directory will contain images that the user will pull from and the `saved`
directory will be where the user saved images will be saved.
3. The app will then download [kCachedImageCount](lib/src/constants.dart) images into the `cached` directory
and then prepopulate [kPrepopulatedImageCount](lib/src/constants.dart) images into the `saved` directory. The images that are saved will show up in the grid below the buttons in the app.
4. As the user interacts with the app, the app will continuously download new images
into `cached` so that the user has access to them when they request a new one.

The decision to use a cache is to ensure that the network requests don't ruin the
UX for the app user.

### No internet connection
By default, the app will keep a few images in the cache so if the user has spotty internet
service, they will be able to pull from the local cache. The number of images that can be
stored in the cache is configurable and stored in the [`lib/src/constants.dart`](lib/src/constants.dart) file. However,
once the cache has been depleted and it can't refill it due to no internet, it will display
an image indicating that the internet service is not connected. In this situation, the user
is still able to view the previously saved images since those images are saved onto the device.

# Future Work
### Reduce start up times
Currently, there is a bit of a delay when the app starts for the first time on a device
because it needs to prepopulate a few saved images as well as load the cache initially. Ideally
this would all happen in the background so that the user has less start up time.

### Increase test coverage to cover UI
Currently, the tests only cover the `CoffeeAPI` class. This class is responsible for going
to the remote endpoint and pulling the images and handling the cache. In the future, it would
be great to make sure that the UI portion of this app is also tested.

### Empty cache handling
If the user depletes the cache and attempts to fetch a new image, they are shown a image that
tells them to "try again" in a moment. Ideally, it would be nice if the app can go into a
loading state and pulls in the next available image. If the internet connection is unavailable,
it should also say that and not attempt to fetch a new image.

### Save to photo library
Currently, when a user wants to save an image, it will be saved into the app's local storage.
It won't be available to the user in their photo library. There should be an additional button
that allows the user to have the image they saved in the app appear in the photo library.
