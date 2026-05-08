import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataCacheService {
  UserDataCacheService._();

  static Future<Directory> _getCacheDir() async {
    return await getApplicationDocumentsDirectory();
  }

  static Future<File?> cachedFileIfExists(String filename) async {
    final dir = await _getCacheDir();
    final file = File('${dir.path}/$filename');
    return await file.exists() ? file : null;
  }

  static Future<File> saveStringToCache(String filename, String contents) async {
    final dir = await _getCacheDir();
    final file = File('${dir.path}/$filename');
    return await file.writeAsString(contents, flush: true);
  }

  static Future<String?> readStringFromCache(String filename) async {
    final file = await cachedFileIfExists(filename);
    if (file == null) return null;
    try {
      return await file.readAsString();
    } catch (_) {
      return null;
    }
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

  /// Sync strategy similar to image cache: compare remote identifier (e.g. profileLink)
  /// If same and cache exists -> return cached file. If different and [jsonData] provided
  /// write it to cache and persist the remote identifier. If no jsonData provided,
  /// just return existing cache (no network fetch here).
  static Future<File?> syncDataByUrlPolicy({
    required String? remoteUrl,
    required String cacheFile,
    required String cachedUrlKey,
    Map<String, dynamic>? jsonData,
  }) async {
    final cachedFile = await cachedFileIfExists(cacheFile);
    if (remoteUrl == null || remoteUrl.isEmpty) {
      return cachedFile;
    }

    final cachedUrl = await getCachedRemoteUrl(cachedUrlKey);
    if (cachedUrl == remoteUrl) {
      if (cachedFile != null) return cachedFile;
      if (jsonData != null) {
        final saved = await saveStringToCache(cacheFile, jsonEncode(jsonData));
        await setCachedRemoteUrl(cachedUrlKey, remoteUrl);
        return saved;
      }
      return null;
    }

    // remoteUrl changed: if jsonData available, persist it; otherwise keep existing
    if (jsonData != null) {
      final saved = await saveStringToCache(cacheFile, jsonEncode(jsonData));
      await setCachedRemoteUrl(cachedUrlKey, remoteUrl);
      return saved;
    }

    return cachedFile;
  }
}
