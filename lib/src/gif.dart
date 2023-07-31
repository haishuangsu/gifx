import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Gif extends StatefulWidget {
  const Gif({
    super.key,
    required this.image,
    required this.controller,
    this.duration = Duration.zero,
    this.loadingPlaceHolder,
    this.repeat = true,
    this.width,
    this.height,
    this.fit,
  });

  Gif.network(
    String url, {
    super.key,
    required this.controller,
    this.duration = Duration.zero,
    this.loadingPlaceHolder,
    this.repeat = true,
    this.width,
    this.height,
    this.fit,
  }) : image = NetImage(url: url);

  Gif.asset(
    String path, {
    super.key,
    required this.controller,
    this.duration = Duration.zero,
    this.loadingPlaceHolder,
    this.repeat = true,
    this.width,
    this.height,
    this.fit,
  }) : image = LocalImage(path: path);

  Gif.memory(
    Uint8List buffer, {
    super.key,
    required this.controller,
    this.duration = Duration.zero,
    this.loadingPlaceHolder,
    this.repeat = true,
    this.width,
    this.height,
    this.fit,
  }) : image = MemoryImage(buffer: buffer);

  final Duration duration;
  final Widget? loadingPlaceHolder;
  final GifController controller;
  final GifImage image;
  final bool repeat;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  State<StatefulWidget> createState() => _GifState();
}

typedef LoadCallBack = void Function();

class _GifState extends State<Gif> with TickerProviderStateMixin {
  var frameCache = <ui.Image>[];
  bool load = false;
  late AnimationController _animationController;
  Duration defalutDuration = const Duration(seconds: 1);
  bool get isPlay => widget.controller.isPlay;

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant Gif oldWidget) {
    if (oldWidget.image != widget.image) {
      widget.controller.sourceDuration = Duration.zero;
      load = false;
      _clearCache();
      _init();
    }

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_animationUpdate);
      widget.controller.addListener(_animationUpdate);
      _play();
    }

    if (oldWidget.duration != widget.duration) {
      _stop();
      _animationController.duration = widget.duration == Duration.zero
          ? widget.controller.sourceDuration == Duration.zero
              ? defalutDuration
              : widget.controller.sourceDuration
          : widget.duration;
      _play();
    }

    if (oldWidget.loadingPlaceHolder != widget.loadingPlaceHolder ||
        oldWidget.repeat != widget.repeat) {
      _stop();
      _play();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _init() {
    _loadFrames(() {
      _loading();
      _initAniamtionController();
      widget.controller.addListener(_animationUpdate);
      _play();
    });
  }

  void _loadFrames(LoadCallBack? callBack) async {
    ui.ImmutableBuffer buffer = await widget.image.resolve();
    ui.Codec codec =
        await PaintingBinding.instance.instantiateImageCodecFromBuffer(buffer);
    widget.controller.frameCount = codec.frameCount;
    for (var i = 0; i < codec.frameCount; i++) {
      ui.FrameInfo frameInfo = await codec.getNextFrame();
      widget.controller.sourceDuration += frameInfo.duration;
      frameCache.add(frameInfo.image.clone());
    }
    if (callBack != null) callBack();
  }

  void _loading() {
    setState(() {
      load = true;
    });
  }

  void _initAniamtionController() {
    _animationController = AnimationController(
      lowerBound: 0.0,
      upperBound: widget.controller.frameCount - 1,
      duration: widget.duration == Duration.zero
          ? widget.controller.sourceDuration == Duration.zero
              ? defalutDuration
              : widget.controller.sourceDuration
          : widget.duration,
      vsync: this,
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset();
        widget.controller.isPlay = false;
      }
    });
  }

  void _animationUpdate() {
    if (isPlay) {
      _play();
    } else {
      _stop();
    }
  }

  void _play() {
    if (widget.repeat) {
      _animationController.repeat();
    } else {
      _animationController.forward();
    }
  }

  void _stop() {
    _animationController.stop();
  }

  void _clearCache() {
    for (var frame in frameCache) {
      frame.dispose();
    }
    frameCache.clear();
  }

  @override
  void dispose() {
    _clearCache();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: load
          ? AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return RawImage(
                  image: frameCache[_animationController.value.toInt()],
                  width: widget.width,
                  height: widget.height,
                  fit: widget.fit,
                );
              },
            )
          : widget.loadingPlaceHolder ??
              CircularProgressIndicator(color: Theme.of(context).primaryColor),
    );
  }
}

class GifController extends ChangeNotifier {
  bool isPlay = true;
  int frameCount = 0;
  Duration sourceDuration = Duration.zero;

  void play() {
    isPlay = true;
    notifyListeners();
  }

  void stop() {
    isPlay = false;
    notifyListeners();
  }
}

abstract class GifImage {
  Future<ui.ImmutableBuffer> resolve();
}

class LocalImage extends GifImage {
  LocalImage({required this.path});
  final String path;

  @override
  Future<ui.ImmutableBuffer> resolve() async {
    return await ui.ImmutableBuffer.fromAsset(path);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is LocalImage && other.path == path;
  }

  @override
  int get hashCode => Object.hash(path.hashCode, path);
}

final _client = HttpClient()..autoUncompress = false;

class NetImage extends GifImage {
  NetImage({required this.url});
  final String url;

  @override
  Future<ui.ImmutableBuffer> resolve() async {
    final request = await _client.getUrl(Uri.base.resolve(url));
    final HttpClientResponse response = await request.close();
    Uint8List bytes = await consolidateHttpClientResponseBytes(response);

    return await ui.ImmutableBuffer.fromUint8List(bytes);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is NetImage && other.url == url;
  }

  @override
  int get hashCode => Object.hash(url.hashCode, url);
}

class MemoryImage extends GifImage {
  MemoryImage({required this.buffer});
  final Uint8List buffer;

  @override
  Future<ui.ImmutableBuffer> resolve() async {
    return await ui.ImmutableBuffer.fromUint8List(buffer);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MemoryImage && other.buffer == buffer;
  }

  @override
  int get hashCode => Object.hash(buffer.hashCode, buffer);
}
