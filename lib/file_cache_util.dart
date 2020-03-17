

import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileCacheUtil
{
  static Directory _applicationDocumentsDirectory;
  static Directory _applicationMediaDirectory;
  static Directory _applicationImageDirectory;

  static void cleanFileCache() async
 {
   if(_applicationDocumentsDirectory == null)
     {
       _applicationDocumentsDirectory = await getApplicationDocumentsDirectory();
     }

   Directory cachePath = Directory("${_applicationDocumentsDirectory.path}/fileache/");
   if (cachePath.existsSync()) {
     await File(cachePath.path).delete(recursive: true);
   }

 }

  static void cleanMediaFileCache() async
  {
    if(_applicationMediaDirectory == null)
      {
        if(_applicationDocumentsDirectory == null) {
          _applicationDocumentsDirectory = await
          getApplicationDocumentsDirectory();
        }
        _applicationMediaDirectory = Directory
          ("${_applicationDocumentsDirectory.path}/fileache/media/");

      }

    if (_applicationMediaDirectory.existsSync()) {
      await File(_applicationMediaDirectory.path).delete(recursive: true);
    }
  }

  static void cleanImageFileCache() async
  {
    if(_applicationImageDirectory == null)
    {
      if(_applicationDocumentsDirectory == null) {
        _applicationDocumentsDirectory = await
        getApplicationDocumentsDirectory();
      }
      _applicationImageDirectory = Directory
        ("${_applicationDocumentsDirectory.path}/fileache/image/");

    }

    if (_applicationImageDirectory.existsSync()) {
      await File(_applicationImageDirectory.path).delete(recursive: true);
    }
  }

  static Future<Directory> getMediaFileCacheDir() async
  {
    if(_applicationMediaDirectory == null)
    {
      if(_applicationDocumentsDirectory == null) {
        _applicationDocumentsDirectory = await
        getApplicationDocumentsDirectory();
      }
      _applicationMediaDirectory = Directory
        ("${_applicationDocumentsDirectory.path}/fileache/media/");

    }

    if(!_applicationMediaDirectory.existsSync())
    {
      _applicationMediaDirectory.createSync(recursive: true);
    }
    return _applicationMediaDirectory;
  }
  static Future<Directory> getImageFileCacheDir() async
  {
    if(_applicationImageDirectory == null)
    {
      if(_applicationDocumentsDirectory == null) {
        _applicationDocumentsDirectory = await
        getApplicationDocumentsDirectory();
      }
      _applicationImageDirectory = Directory
        ("${_applicationDocumentsDirectory.path}/fileache/image/");

    }

    if(!_applicationImageDirectory.existsSync())
    {
      _applicationImageDirectory.createSync(recursive: true);
    }
    return _applicationImageDirectory;
  }

}
