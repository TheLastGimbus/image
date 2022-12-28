import 'dart:io';
import 'package:image/image.dart';
import 'package:test/test.dart';

import '../_test_util.dart';

void main() {
  group('Format', () {
    group('gif', () {
      test('cmd', () async {
        Command()
            ..decodeGifFile('test/_data/gif/cars.gif')
            ..copyResize(width: 64)
            ..encodeGifFile('$testOutputPath/gif/cars_cmd.gif')
            ..execute();
      });

      final dir = Directory('test/_data/gif');
      final files = dir.listSync();
      for (var f in files.whereType<File>()) {
        if (!f.path.endsWith('.gif')) {
          continue;
        }

        final name = f.uri.pathSegments.last;
        test(name, () {
          final bytes = f.readAsBytesSync();
          final anim = GifDecoder().decode(bytes);
          expect(anim, isNotNull);

          if (anim != null) {
            final gif = encodeGif(anim);
            if (anim.length > 1) {
              File('$testOutputPath/gif/${name}_anim.gif')
                ..createSync(recursive: true)
                ..writeAsBytesSync(gif);
            }

            for (var frame in anim.frames) {
              final gif = encodeGif(frame, singleFrame: true);
              File('$testOutputPath/gif/${name}_${frame.frameIndex}.gif')
                ..createSync(recursive: true)
                ..writeAsBytesSync(gif);
            }

            final a2 = decodeGif(gif)!;
            expect(a2, isNotNull);
            expect(a2.length, equals(anim.length));
            expect(a2.width, equals(anim.width));
            expect(a2.height, equals(anim.height));
            for (var frame in anim.frames) {
              final i2 = a2.frames[frame.frameIndex];
              for (final p in frame) {
                final p2 = i2.getPixel(p.x, p.y);
                expect(p, equals(p2));
              }
            }
          }
        });
      }

      test('encodeAnimation', () {
        final anim = Image(width: 480, height: 120)
        ..loopCount = 10;
        for (var i = 0; i < 10; i++) {
          final image = i == 0 ? anim : anim.addFrame();
          drawString(image, arial48, 100, 60, i.toString());
        }

        final gif = encodeGif(anim);
        File('$testOutputPath/gif/encodeAnimation.gif')
          ..createSync(recursive: true)
          ..writeAsBytesSync(gif);

        final anim2 = GifDecoder().decode(gif)!;
        expect(anim2.numFrames, equals(10));
        expect(anim2.loopCount, equals(10));
      });

      test('encodeAnimation with variable FPS', () {
        final anim = Image(width: 480, height: 120);
        for (var i = 1; i <= 3; i++) {
          final image = i == 1 ? anim : anim.addFrame()
          ..frameDuration = i * 1000;
          drawString(image, arial24, 50, 50, 'This frame is $i second(s) long');
        }

        const name = 'encodeAnimation_variable_fps';
        final gif = encodeGif(anim);
        File('$testOutputPath/gif/$name.gif')
          ..createSync(recursive: true)
          ..writeAsBytesSync(gif);

        final anim2 = GifDecoder().decode(gif)!;
        expect(anim2.numFrames, equals(3));
        expect(anim2.loopCount, equals(0));
        expect(anim2.frames[0].frameDuration, equals(1000));
        expect(anim2.frames[1].frameDuration, equals(2000));
        expect(anim2.frames[2].frameDuration, equals(3000));
      });

      test('encode_small_gif', () {
        final image = decodeGif(
            File('test/_data/gif/buck_24.gif').readAsBytesSync())!;
        final resized = copyResize(image, width: 16, height: 16);
        final gif = encodeGif(resized);
        File('$testOutputPath/gif/encode_small_gif.gif')
          ..createSync(recursive: true)
          ..writeAsBytesSync(gif);
      });
    });
  });
}
