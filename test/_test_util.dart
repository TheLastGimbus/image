//import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:image/image.dart';
import 'package:test/test.dart';

//final testOutputPath = '${Directory.systemTemp.createTempSync().path}/out';
const testOutputPath = './out';

int hashImage(Image image) {
  var hash = 0;
  var x = 0;
  var y = 0;

  final rgbaDouble = Float64List(4);
  final rgba8 = Uint8List.view(rgbaDouble.buffer);
  for (final p in image) {
    for (var ci = 0; ci < p.length; ++ci) {
      rgbaDouble[ci] = p[ci].toDouble();
    }
    hash = getCrc32(rgba8, hash);
    if (x != p.x || y != p.y) {
      throw ImageException('Invalid Pixel index');
    }
    x++;
    if (x == image.width) {
      x = 0;
      y++;
    }
  }

  return hash;
}

void testImageEquals(Image image, Image image2) {
  expect(image2.width, equals(image.width));
  expect(image2.height, equals(image.height));
  expect(image2.numChannels, equals(image.numChannels));
  expect(image2.hasPalette, equals(image.hasPalette));
  final c = image.iterator..moveNext();
  for (var p2 in image2) {
    final p1 = c.current;
    expect(p2, equals(p1));
    c.moveNext();
  }
}
