import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../models/video_model.dart';

class FloatingVideoPlayer extends StatefulWidget {
  final VideoModel video;
  final VoidCallback onClose;

  const FloatingVideoPlayer({
    super.key,
    required this.video,
    required this.onClose,
  });

  @override
  State<FloatingVideoPlayer> createState() => _FloatingVideoPlayerState();
}

class _FloatingVideoPlayerState extends State<FloatingVideoPlayer> {
  late YoutubePlayerController _controller;
  bool _isExpanded = true;
  Offset _position = Offset(20, 100); // Initial position
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    );
    // _incrementViews();
  }

  // void _incrementViews() {
  //   if (widget.video.id != null) {
  //     context.read<VideoProvider>().incrementViews(widget.video.id!);
  //   }
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _clampPosition(Offset position, Size size, double playerWidth, double playerHeight) {
    double x = position.dx;
    double y = position.dy;

    // Clamp x position
    x = x.clamp(0.0, size.width - playerWidth);
    // Clamp y position
    y = y.clamp(0.0, size.height - playerHeight - 100); // Account for safe area

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final playerWidth = _isExpanded ? size.width : size.width * 0.4;
    final playerHeight = _isExpanded ? size.width * 9 / 16 : size.width * 0.4 * 9 / 16;

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanStart: (_) => setState(() => _isDragging = true),
        onPanUpdate: (details) {
          setState(() {
            _position = _clampPosition(
              Offset(
                _position.dx + details.delta.dx,
                _position.dy + details.delta.dy,
              ),
              size,
              playerWidth,
              playerHeight,
            );
          });
        },
        onPanEnd: (_) => setState(() => _isDragging = false),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: playerWidth,
          height: playerHeight + (_isExpanded ? 56 : 0), // Add space for controls when expanded
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: YoutubePlayerBuilder(
                      player: YoutubePlayer(
                        controller: _controller,
                        showVideoProgressIndicator: _isExpanded,
                        progressIndicatorColor: Theme.of(context).primaryColor,
                        progressColors: ProgressBarColors(
                          playedColor: Theme.of(context).primaryColor,
                          handleColor: Theme.of(context).primaryColor,
                        ),
                        actionsPadding: EdgeInsets.all(8),
                      ),
                      builder: (context, player) => SizedBox(
                        width: playerWidth,
                        height: playerHeight,
                        child: player,
                      ),
                    ),
                  ),
                  if (!_isDragging)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isExpanded ? Icons.compress : Icons.expand,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _isExpanded = !_isExpanded),
                            padding: EdgeInsets.all(4),
                            constraints: BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: widget.onClose,
                            padding: EdgeInsets.all(4),
                            constraints: BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  if (!_isDragging && !_isExpanded)
                    Positioned(
                      left: 4,
                      right: 60,
                      bottom: 4,
                      child: Text(
                        widget.video.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              if (_isExpanded) ...[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    width: double.infinity,
                    color: Colors.black87,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.video.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.remove_red_eye,
                              size: 14,
                              color: Colors.grey[400],
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${widget.video.views + 1} views',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            Spacer(),
                            Text(
                              widget.video.createdAt.toString().substring(0, 16),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}