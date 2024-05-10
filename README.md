# Coffee by Elias

Welcome fellow Coffee enthusiasts! I hope this app can give you some fun coffee
images to view while waiting for a flight, your doctor's waiting room, and even
while waiting for your coffee!

[![Watch the video](public/Video%20screen.png)](https://github-production-user-asset-6210df.s3.amazonaws.com/42216813/329642228-40dd200c-43b9-4707-a7d2-f674109fe030.mp4?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAVCODYLSA53PQK4ZA%2F20240510%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20240510T160305Z&X-Amz-Expires=300&X-Amz-Signature=5b96df807ebbfb79feed4f65283de07c30265f903009e36c31abec1f6abda8c4&X-Amz-SignedHeaders=host&actor_id=42216813&key_id=0&repo_id=797929422)


# Usage Instructions

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
3. The app will then download [kCachedImageCount] images into the `cached` directory
and then prepopulate [kPrepopulatedImageCount] images into the `saved` directory. The images that are saved will show up in the grid below the buttons in the app.
4. As the user interacts with the app, the app will continuously download new images
into `cached` so that the user has access to them when they request a new one.

The decision to use a cache is to ensure that the network requests don't ruin the
UX for the app user.

### No internet connection
By default, the app will keep a few images in the cache so if the user has spotty internet
service, they will be able to pull from the local cache. The number of images that can be
stored in the cache is configurable and stored in the `lib/src/constants.dart` file. However,
once the cache has been depleted and it can't refill it due to no internet, it will display
an image indicating that the internet service is not connected. In this situation, the user
is still able to view the previously saved images since those images are saved onto the device.
