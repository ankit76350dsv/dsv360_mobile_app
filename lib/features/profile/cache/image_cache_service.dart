import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageCacheService {
  ImageCacheService._();

  static Future<Directory> getCacheDir() async {
    return await getApplicationDocumentsDirectory();
  }

  static Future<File?> cachedFileIfExists(String filename) async {
    final dir = await getCacheDir();
    final file = File('${dir.path}/$filename');
    return await file.exists() ? file : null;
  }

  static Future<File> saveBytesToCache(String filename, List<int> bytes) async {
    final dir = await getCacheDir();
    final file = File('${dir.path}/$filename');
    return await file.writeAsBytes(bytes, flush: true);
  }

  static Future<String?> getCachedRemoteUrl(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> setCachedRemoteUrl(String key, String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, url);
  }

  static Future<void> deleteCachedFile(String filename) async {
    final prev = await cachedFileIfExists(filename);
    if (prev != null) {
      try {
        await prev.delete();
      } catch (_) {}
    }
  }

  static Future<void> evictCachedImageProvider(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      await FileImage(File(path)).evict();
    } catch (_) {}
  }

  static Future<List<int>?> downloadImageBytes(String url) async {
    try {
      if (url.isEmpty) return null;
      final uri = Uri.parse(url);
      final HttpClient client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != 200) return null;
      return await consolidateHttpClientResponseBytes(response);
    } catch (e) {
      debugPrint('Download bytes failed: $e');
      return null;
    }
  }

  static Future<File?> downloadToCacheAndPersistUrl({
    required String? remoteUrl,
    required String cacheFile,
    required String cachedUrlKey,
  }) async {
    if (remoteUrl == null || remoteUrl.isEmpty || !remoteUrl.startsWith('http')) {
      return await cachedFileIfExists(cacheFile);
    }

    final serverBytes = await downloadImageBytes(remoteUrl);
    if (serverBytes == null) {
      return await cachedFileIfExists(cacheFile);
    }

    await deleteCachedFile(cacheFile);
    final saved = await saveBytesToCache(cacheFile, serverBytes);
    await setCachedRemoteUrl(cachedUrlKey, remoteUrl);
    return saved;
  }

  static Future<File?> syncCacheByUrlPolicy({
    required String? remoteUrl,
    required String cacheFile,
    required String cachedUrlKey,
  }) async {
    final cachedFile = await cachedFileIfExists(cacheFile);
    if (remoteUrl == null || remoteUrl.isEmpty || !remoteUrl.startsWith('http')) {
      return cachedFile;
    }

    final cachedUrl = await getCachedRemoteUrl(cachedUrlKey);

    // Same URL from server: always load from cache.
    if (cachedUrl == remoteUrl) {
      if (cachedFile != null) return cachedFile;
      return await downloadToCacheAndPersistUrl(
        remoteUrl: remoteUrl,
        cacheFile: cacheFile,
        cachedUrlKey: cachedUrlKey,
      );
    }

    // URL changed: replace old cache with fresh server image.
    return await downloadToCacheAndPersistUrl(
      remoteUrl: remoteUrl,
      cacheFile: cacheFile,
      cachedUrlKey: cachedUrlKey,
    );
  }
}
