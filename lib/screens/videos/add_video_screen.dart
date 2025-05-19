import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../models/video_model.dart';
import '../../providers/video_provider.dart';

class AddVideoScreen extends StatefulWidget {
  const AddVideoScreen({super.key});

  @override
  _AddVideoScreenState createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _titleArController = TextEditingController();

  YoutubePlayerController? _youtubeController;
  VideoModel? _video;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _titleArController.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Video'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _handleSubmit,
            icon: _isLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white),
            )
                : Icon(Icons.save, color: Colors.white),
            label: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildUrlSection(),
            if (_video != null) ...[
              SizedBox(height: 24),
              _buildPreviewSection(),
              SizedBox(height: 24),
              _buildTitleSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUrlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YouTube URL',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _urlController,
          decoration: InputDecoration(
            hintText: 'Enter YouTube video URL',
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(Icons.check_circle),
              onPressed: _validateUrl,
            ),
          ),
          validator: (value) =>
          value?.isEmpty == true ? 'URL is required' : null,
        ),
        if (_error != null)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        if (_youtubeController != null)
          YoutubePlayer(
            controller: _youtubeController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Theme.of(context).primaryColor,
            progressColors: ProgressBarColors(
              playedColor: Theme.of(context).primaryColor,
              handleColor: Theme.of(context).primaryColor,
            ),
            onReady: () {
              _youtubeController!.addListener(() {
                if (mounted) setState(() {});
              });
            },
          ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Title (English)',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
          value?.isEmpty == true ? 'Title is required' : null,
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _titleArController,
          decoration: InputDecoration(
            labelText: 'Title (Arabic)',
            border: OutlineInputBorder(),
          ),
          textDirection: TextDirection.rtl,
          validator: (value) =>
          value?.isEmpty == true ? 'Arabic title is required' : null,
        ),
      ],
    );
  }

  Future<void> _validateUrl() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      final provider = context.read<VideoProvider>();
      final video = await provider.validateYoutubeUrl(_urlController.text);

      if (video != null) {
        setState(() {
          _video = video;
          _youtubeController = YoutubePlayerController(
            initialVideoId: video.videoId,
            flags: YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
            ),
          );
        });
      } else {
        setState(() {
          _error = provider.error ?? 'Invalid YouTube URL';
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() || _video == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<VideoProvider>();

      final video = _video!.copyWith(
        title: _titleController.text,
        titleAr: _titleArController.text,
        createdAt: DateTime.now(),
        createdBy: 'Ramy888',
      );

      await provider.addVideo(video);

      if (provider.status == VideoOperationStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video added successfully')),
        );
        Navigator.pop(context);
      } else if (provider.status == VideoOperationStatus.error) {
        setState(() => _error = provider.error);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}