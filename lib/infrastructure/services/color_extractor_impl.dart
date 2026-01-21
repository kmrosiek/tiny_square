import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:palette_generator_master/palette_generator_master.dart';

import '../../core/logger/logger.dart';
import '../../domain/entities/extracted_colors.dart';
import '../../domain/services/color_extractor.dart';

class ColorExtractorImpl implements ColorExtractor {
  ColorExtractorImpl({required this.logger}) {
    _initializeIsolate();
  }

  static const _logTag = '[ColorExtractorImpl]';

  final Logger logger;

  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;
  final Completer<SendPort> _isolateReady = Completer<SendPort>();
  int _requestId = 0;
  final Map<int, Completer<(int?, int?, int?, int?)>> _pendingRequests = {};
  bool _isDisposed = false;

  Future<void> _initializeIsolate() async {
    logger.debug('$_logTag: Initializing isolate');
    _receivePort = ReceivePort();

    try {
      _isolate = await Isolate.spawn(_isolateEntryPoint, _receivePort!.sendPort, errorsAreFatal: false);
    } catch (e, stackTrace) {
      logger.error('$_logTag: Failed to spawn isolate', e, stackTrace);
      _receivePort?.close();
      _receivePort = null;
      _isolateReady.completeError(e, stackTrace);
      return;
    }

    _receivePort!.listen(
      (message) {
        if (message is SendPort) {
          _sendPort = message;
          _isolateReady.complete(message);
          logger.info('$_logTag: Isolate initialized and ready');
        } else if (message is Map<String, dynamic>) {
          final requestId = message['requestId'] as int;
          if (message.containsKey('error')) {
            final error = message['error'] as String;
            logger.error('$_logTag: Error processing request $requestId', Exception(error));
            final completer = _pendingRequests.remove(requestId);
            completer?.completeError(Exception(error));
          } else {
            final result = message['result'] as (int?, int?, int?, int?);
            logger.debug('$_logTag: Received color extraction result for request $requestId');
            final completer = _pendingRequests.remove(requestId);
            completer?.complete(result);
          }
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.error('$_logTag: Receive port error', error, stackTrace);
        // Handle receive port errors
        for (final completer in _pendingRequests.values) {
          completer.completeError(error, stackTrace);
        }
        _pendingRequests.clear();
      },
      cancelOnError: false,
    );
  }

  @override
  Future<ExtractedColors> extractColors(Uint8List imageBytes) async {
    if (_isDisposed) {
      logger.warning('$_logTag: Attempted to extract colors after disposal');
      throw StateError('ColorExtractorImpl has been disposed');
    }

    // Ensure isolate is ready
    if (!_isolateReady.isCompleted) {
      logger.debug('$_logTag: Waiting for isolate to be ready');
      await _isolateReady.future;
    }

    final requestId = _requestId++;
    logger.debug('$_logTag: Extracting colors for request $requestId. Image size: ${imageBytes.length} bytes');
    final completer = Completer<(int?, int?, int?, int?)>();
    _pendingRequests[requestId] = completer;

    // Convert Uint8List to TransferableTypedData for efficient transfer
    final transferable = TransferableTypedData.fromList([imageBytes]);

    _sendPort!.send({'requestId': requestId, 'imageBytes': transferable});

    try {
      final result = await completer.future;
      logger.info('$_logTag: Successfully extracted colors for request $requestId');
      return ExtractedColors(
        lightBackground: result.$1 != null ? Color(result.$1!) : null,
        darkBackground: result.$2 != null ? Color(result.$2!) : null,
        lightTextColor: result.$3 != null ? Color(result.$3!) : null,
        darkTextColor: result.$4 != null ? Color(result.$4!) : null,
      );
    } catch (e, stackTrace) {
      logger.error('$_logTag: Failed to extract colors for request $requestId', e, stackTrace);
      rethrow;
    }
  }

  @override
  void dispose() {
    if (_isDisposed) {
      return;
    }
    logger.debug('$_logTag: Disposing ColorExtractorImpl');
    _isDisposed = true;

    // Cancel all pending requests
    final pendingCount = _pendingRequests.length;
    if (pendingCount > 0) {
      logger.debug('$_logTag: Cancelling $pendingCount pending requests');
    }
    for (final completer in _pendingRequests.values) {
      completer.completeError(StateError('ColorExtractorImpl disposed'));
    }
    _pendingRequests.clear();

    // Close receive port and kill isolate
    _receivePort?.close();
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
    _receivePort = null;
    logger.info('$_logTag: ColorExtractorImpl disposed');
  }
}

// Entry point for the isolate
void _isolateEntryPoint(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    if (message is Map<String, dynamic>) {
      final requestId = message['requestId'] as int;
      final transferable = message['imageBytes'] as TransferableTypedData;

      try {
        final imageBytes = transferable.materialize().asUint8List();
        final result = _extractColorsTask(imageBytes);
        sendPort.send({'requestId': requestId, 'result': result});
      } catch (e) {
        sendPort.send({'requestId': requestId, 'error': e.toString()});
      }
    }
  });
}

(int?, int?, int?, int?) _extractColorsTask(Uint8List imageBytes) {
  final image = img.decodeImage(imageBytes);
  if (image == null) {
    return (null, null, null, null);
  }

  final thumbnail = img.copyResize(image, width: 120);

  final Map<int, int> pixelCounts = {};

  for (final pixel in thumbnail) {
    final int a = pixel.a.toInt();
    final int r = pixel.r.toInt();
    final int g = pixel.g.toInt();
    final int b = pixel.b.toInt();

    final int argb = (a << 24) | (r << 16) | (g << 8) | b;

    pixelCounts[argb] = (pixelCounts[argb] ?? 0) + 1;
  }

  final List<PaletteColorMaster> paletteColors = pixelCounts.entries.map((entry) {
    return PaletteColorMaster(Color(entry.key), entry.value);
  }).toList();

  final palette = PaletteGeneratorMaster.fromColors(paletteColors);

  final lightBg = palette.lightVibrantColor?.color ?? palette.lightMutedColor?.color ?? palette.dominantColor?.color;
  final darkBg = palette.darkVibrantColor?.color ?? palette.darkMutedColor?.color ?? palette.dominantColor?.color;
  final lightText = palette.darkVibrantColor?.color ?? palette.darkMutedColor?.color ?? palette.dominantColor?.color;
  final darkText = palette.lightVibrantColor?.color ?? palette.lightMutedColor?.color ?? palette.dominantColor?.color;

  return (lightBg?.toARGB32(), darkBg?.toARGB32(), lightText?.toARGB32(), darkText?.toARGB32());
}
