<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

A gif library, you can control the gif play and pause, you can set the gif playback time and thus control the frame rate.

![Screenshot](https://github.com/haishuangsu/gifx/blob/master/screenshot/screenshot.gif)


## Getting started

This will add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):

```yaml
dependencies:
  gifx: ^1.0.0
```



## Usage

### From Assets

```dart
    Gif.asset(
      'images/test.gif',
      controller: _controller,
      duration: const Duration(milliseconds: 3000), // You can change the source gif duration.
    )
```

### From Network

```dart
    Gif.network(
      'http://c-ssl.duitang.com/uploads/item/201803/26/20180326190951_QvM5V.thumb.1000_0.gif',
      controller: _controller,
    )
```

### From Memory
```dart
    Gif.memory(
      buffer,
      controller: _controller,
    )
```

### Controller
```dart
final _controller = GifController();

_controller.play();

_controller.stop();

_controller.frameCount;     // The source gif frame count

_controller.sourceDuration; // The source gif duration
```
