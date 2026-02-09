import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/compressed_file.dart';

class StorageService extends ChangeNotifier {
  static const String _historyKey = 'compression_history';
  static const int _maxHistoryItems = 20;

  List<CompressedFile> _history = [];
  
  List<CompressedFile> get history => List.unmodifiable(_history);

  Future<void> init() async {
    try {
      await _loadHistory();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize storage service: $e');
      }
      _history = [];
    }
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];
      
      _history = historyJson
          .map((jsonString) {
            try {
              return CompressedFile.fromJson(json.decode(jsonString));
            } catch (e) {
              if (kDebugMode) {
                print('Error parsing history item: $e');
              }
              return null;
            }
          })
          .whereType<CompressedFile>()
          .toList();
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading history: $e');
      }
    }
  }

  Future<void> addToHistory(CompressedFile file) async {
    _history.insert(0, file);
    
    if (_history.length > _maxHistoryItems) {
      _history = _history.sublist(0, _maxHistoryItems);
    }
    
    await _saveHistory();
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _history
          .map((file) => json.encode(file.toJson()))
          .toList();
      
      await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving history: $e');
      }
    }
  }

  Future<void> clearHistory() async {
    _history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    notifyListeners();
  }

  Future<void> removeFromHistory(CompressedFile file) async {
    _history.removeWhere((item) => 
      item.compressedPath == file.compressedPath
    );
    await _saveHistory();
    notifyListeners();
  }
}
