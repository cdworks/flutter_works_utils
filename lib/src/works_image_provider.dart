

import 'package:flutter/foundation.dart';
import 'dart:ui' as ui show Codec;
import 'dart:ui' show hashValues;
import 'package:flutter/painting.dart' show ImageProvider,ImageConfiguration,
DecoderCallback,ImageStreamCompleter,MultiFrameImageStreamCompleter,
NetworkImageLoadException,debugNetworkImageHttpClientProvider,ImageChunkEvent;
import 'dart:io';
import 'dart:typed_data';
import 'dart:async' show StreamController;



class WorksFileImage extends ImageProvider<WorksFileImage> {
  /// Creates an object that decodes a [File] as an image.
  ///
  /// The arguments must not be null.
  const WorksFileImage(this.file, { this.scale = 1.0 ,this.cacheWidth,this.cacheHeight})
      : assert(file != null),
        assert(scale != null);

  /// The file to decode into an image.
  final File file;

  final  int cacheWidth;
  final  int cacheHeight;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  @override
  Future<WorksFileImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<WorksFileImage>(this);
  }

  @override
  ImageStreamCompleter load(WorksFileImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      informationCollector: () sync* {
        yield ErrorDescription('Path: ${file?.path}');
      },
    );
  }

  Future<ui.Codec> _loadAsync(WorksFileImage key, DecoderCallback decode) async {
    assert(key == this);

    final Uint8List bytes = await file.readAsBytes();
    if (bytes.lengthInBytes == 0)
      return null;

    if(cacheWidth != null || cacheHeight != null)
      {
        return await decode(bytes,cacheWidth:cacheWidth,cacheHeight:cacheHeight);
      }
    return await decode(bytes);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is WorksFileImage
        && other.file?.path == file?.path
        && other.scale == scale;
  }

  @override
  int get hashCode => hashValues(file?.path, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'FileImage')}("${file?.path}", scale: $scale)';
}

class _WorksNetworkImage extends ImageProvider<WorksNetworkImage> implements
    WorksNetworkImage {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments [url] and [scale] must not be null.
  const _WorksNetworkImage(this.url, { this.scale = 1.0, this.headers ,this
      .cacheWidth,this.cacheHeight})
      : assert(url != null),
        assert(scale != null);

  @override
  final String url;

  @override
  final double scale;

  @override
  final int cacheWidth;

  @override
  final int cacheHeight;

  @override
  final Map<String, String> headers;

  @override
  Future<_WorksNetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_WorksNetworkImage>(this);
  }

  @override
  ImageStreamCompleter load(WorksNetworkImage key, DecoderCallback decode) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final StreamController<ImageChunkEvent> chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<WorksNetworkImage>('Image key', key),
        ];
      },
    );
  }

  // Do not access this field directly; use [_httpClient] instead.
  // We set `autoUncompress` to false to ensure that we can trust the value of
  // the `Content-Length` HTTP header. We automatically uncompress the content
  // in our call to [consolidateHttpClientResponseBytes].
  static final HttpClient _sharedHttpClient = HttpClient()..autoUncompress = false;

  static HttpClient get _httpClient {
    HttpClient client = _sharedHttpClient;
    assert(() {
      if (debugNetworkImageHttpClientProvider != null)
        client = debugNetworkImageHttpClientProvider();
      return true;
    }());
    return client;
  }

  Future<ui.Codec> _loadAsync(
      _WorksNetworkImage key,
      StreamController<ImageChunkEvent> chunkEvents,
      DecoderCallback decode,
      ) async {
    try {
      assert(key == this);

      final Uri resolved = Uri.base.resolve(key.url);
      final HttpClientRequest request = await _httpClient.getUrl(resolved);
      headers?.forEach((String name, String value) {
        request.headers.add(name, value);
      });
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok)
        throw NetworkImageLoadException(statusCode: response.statusCode, uri: resolved);

      final Uint8List bytes = await consolidateHttpClientResponseBytes(
        response,
        onBytesReceived: (int cumulative, int total) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ));
        },
      );
      if (bytes.lengthInBytes == 0)
        throw Exception('NetworkImage is an empty file: $resolved');
      if(cacheWidth != null || cacheHeight != null)
      {
        print('cached bytes');
        return  decode(bytes,cacheWidth:cacheWidth,cacheHeight:cacheHeight);
      }
      return decode(bytes);
    } finally {
      chunkEvents.close();
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is _WorksNetworkImage
        && other.url == url
        && other.scale == scale;
  }

  @override
  int get hashCode => hashValues(url, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'NetworkImage')}("$url", scale: $scale)';

}

abstract class WorksNetworkImage extends ImageProvider<WorksNetworkImage> {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments [url] and [scale] must not be null.
  const factory WorksNetworkImage(String url, { double scale, Map<String,
      String> headers,int cacheWidth,int  cacheHeight}) = _WorksNetworkImage;

  /// The URL from which the image will be fetched.
  String get url;

  /// The scale to place in the [ImageInfo] object of the image.
  double get scale;

  int get cacheWidth;
  int get cacheHeight;

  /// The HTTP headers that will be used with [HttpClient.get] to fetch image from network.
  ///
  /// When running flutter on the web, headers are not used.
  Map<String, String> get headers;

  @override
  ImageStreamCompleter load(WorksNetworkImage key, DecoderCallback decode);
}

class WorksMemoryImage extends ImageProvider<WorksMemoryImage> {
  /// Creates an object that decodes a [Uint8List] buffer as an image.
  ///
  /// The arguments must not be null.
  const WorksMemoryImage(this.bytes, { this.scale = 1.0 ,this.cacheWidth,this.cacheHeight})
      : assert(bytes != null),
        assert(scale != null);

  /// The bytes to decode into an image.
  final Uint8List bytes;

  final  int cacheWidth;
  final  int cacheHeight;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  @override
  Future<WorksMemoryImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<WorksMemoryImage>(this);
  }

  @override
  ImageStreamCompleter load(WorksMemoryImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
    );
  }

  Future<ui.Codec> _loadAsync(WorksMemoryImage key, DecoderCallback decode) {
    assert(key == this);
    if(cacheWidth != null || cacheHeight != null)
    {
      return  decode(bytes,cacheWidth:cacheWidth,cacheHeight:cacheHeight);
    }
    return decode(bytes);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    return other is WorksMemoryImage
        && other.bytes == bytes
        && other.scale == scale;
  }

  @override
  int get hashCode => hashValues(bytes.hashCode, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'MemoryImage')}(${describeIdentity(bytes)}, scale: $scale)';
}