import 'package:flutter/material.dart';
import 'dart:io';
import '../models/news_model.dart';
import '../services/news_service.dart';

enum NewsOperationStatus {
  initial,
  loading,
  success,
  error
}

class NewsProvider extends ChangeNotifier {
  final NewsService _newsService = NewsService();
  NewsOperationStatus _status = NewsOperationStatus.initial;
  String? _error;
  bool _isLoading = false;

  NewsOperationStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Stream<List<NewsModel>> getNews({bool activeOnly = true}) {
    return _newsService.getNews(activeOnly: activeOnly);
  }

  Future<void> addNews(NewsModel news, List<File> images) async {
    try {
      _setLoading(true);
      _status = NewsOperationStatus.loading;
      await _newsService.addNews(news, images);
      _status = NewsOperationStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = NewsOperationStatus.error;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> toggleNewsStatus(String newsId, bool isActive) async {
    try {
      _setLoading(true);
      await _newsService.toggleNewsStatus(newsId, isActive);
      _status = NewsOperationStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = NewsOperationStatus.error;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void resetStatus() {
    _status = NewsOperationStatus.initial;
    _error = null;
    notifyListeners();
  }
}