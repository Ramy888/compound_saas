import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';

enum VideoOperationStatus {
  initial,
  loading,
  success,
  error
}

class VideoProvider extends ChangeNotifier {
  final VideoService _videoService = VideoService();
  VideoOperationStatus _status = VideoOperationStatus.initial;
  String? _error;
  bool _isLoading = false;

  VideoOperationStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Stream<List<VideoModel>> getVideos({bool activeOnly = true}) {
    return _videoService.getVideos(activeOnly: activeOnly);
  }

  Future<VideoModel?> validateYoutubeUrl(String url) async {
    try {
      _setLoading(true);
      _status = VideoOperationStatus.loading;

      // Extract video ID from URL
      final videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId == null) {
        throw 'Invalid YouTube URL';
      }

      // Get video details using YouTube API (if you have API key)
      // For now, we'll just use the thumbnail URL
      final thumbnailUrl = 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

      return VideoModel(
        youtubeUrl: url,
        thumbnailUrl: thumbnailUrl,
        videoId: videoId,
        title: '',
        titleAr: '',
        createdBy: 'Ramy888',
        createdAt: DateTime.now(),
      );

    } catch (e) {
      _error = e.toString();
      _status = VideoOperationStatus.error;
      return null;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> addVideo(VideoModel video) async {
    try {
      _setLoading(true);
      _status = VideoOperationStatus.loading;
      await _videoService.addVideo(video);
      _status = VideoOperationStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = VideoOperationStatus.error;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> toggleVideoStatus(String videoId, bool isActive) async {
    try {
      _setLoading(true);
      await _videoService.toggleVideoStatus(videoId, isActive);
      _status = VideoOperationStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = VideoOperationStatus.error;
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
    _status = VideoOperationStatus.initial;
    _error = null;
    notifyListeners();
  }
}