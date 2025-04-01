import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<File?> compressImage(File imageFile) async {
  final String targetPath = '${imageFile.path}_compressed.jpg';
  var result = await FlutterImageCompress.compressAndGetFile(
    imageFile.absolute.path,
    targetPath,
    quality: 40,
    minWidth: 800,
    minHeight: 800,
  );
  if (result == null) return null;
  File compressedFile = File(result.path);

  int fileSize = compressedFile.lengthSync();
  print("Compressed file size: ${fileSize / 1024} KB");
  // if (fileSize > 800 * 1024) {
  //   return await compressImage(compressedFile);
  // }
  return compressedFile;
}
