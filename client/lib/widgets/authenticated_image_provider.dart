import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../repositories/user_repository.dart';
import '../managers/user_manager.dart';

class AuthenticatedImageProvider
    extends ImageProvider<AuthenticatedImageProvider> {
  AuthenticatedImageProvider();

  @override
  Future<AuthenticatedImageProvider> obtainKey(
      ImageConfiguration configuration) {
    return SynchronousFuture<AuthenticatedImageProvider>(this);
  }

  @override
  ImageStreamCompleter load(
      AuthenticatedImageProvider key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(decode),
      scale: 1.0,
      informationCollector: () sync* {
        yield DiagnosticsProperty<ImageProvider>('Image provider', this);
        yield DiagnosticsProperty<AuthenticatedImageProvider>('Image key', key);
      },
    );
  }

  Future<ui.Codec> _loadAsync(ImageDecoderCallback decode) async {
    try {
      print('loading avatar...');
      final bytes =
          await UserRepository().getAvatar(UserManager().currentUser?.id ?? 0);
      if (bytes != null) {
        // Decode the image bytes into an ImageCodec
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        final codec = await decode(buffer);
        return codec;
      } else {
        throw Exception('Failed to load avatar');
      }
    } catch (e) {
      print('Error loading avatar: $e');
      // You might want to return a placeholder image here
      throw Exception('Failed to load avatar');
    }
  }
}
