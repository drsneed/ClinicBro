import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import '../repositories/user_repository.dart';
import '../managers/user_manager.dart';

class AuthenticatedImageProvider
    extends ImageProvider<AuthenticatedImageProvider> {
  AuthenticatedImageProvider() {
    print('AuthenticatedImageProvider constructor called');
  }

  @override
  Future<AuthenticatedImageProvider> obtainKey(
      ImageConfiguration configuration) {
    return SynchronousFuture<AuthenticatedImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
      AuthenticatedImageProvider key, ImageDecoderCallback decode) {
    print('loadImage method called');
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(decode),
      scale: 1.0,
      debugLabel: 'AuthenticatedImageProvider',
      informationCollector: () sync* {
        yield DiagnosticsProperty<ImageProvider>('Image provider', this);
        yield DiagnosticsProperty<AuthenticatedImageProvider>('Image key', key);
      },
    );
  }

  Future<ui.Codec> _loadAsync(ImageDecoderCallback decode) async {
    print('_loadAsync started');
    try {
      print('Attempting to load avatar...');
      final userId = UserManager().currentUser?.id;
      print('Current user ID: $userId');
      final bytes = await UserRepository().getAvatar(userId ?? 0);
      if (bytes != null) {
        print('Avatar bytes loaded, length: ${bytes.length}');
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        print('ImmutableBuffer created');
        final codec = await decode(buffer);
        print('Image decoded successfully');
        return codec;
      } else {
        print('Avatar bytes were null');
        throw Exception('Failed to load avatar: bytes were null');
      }
    } catch (e) {
      print('Error in _loadAsync: $e');
      // You might want to return a placeholder image here
      throw Exception('Failed to load avatar: $e');
    }
  }
}
