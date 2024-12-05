import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.color,
    required this.viewOnly,
  });

  final String videoUrl;
  final Color color;
  final bool viewOnly;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isPlaying = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Try to load video from cache
      final fileInfo =
          await DefaultCacheManager().getFileFromCache(widget.videoUrl);
      final videoFile = fileInfo?.file ??
          await DefaultCacheManager().getSingleFile(widget.videoUrl);

      _videoPlayerController = VideoPlayerController.file(videoFile);
      await _videoPlayerController?.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
      );

      if (mounted) {
        // Check if widget is still in the tree
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print("Error initializing video player: $e");
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  color: widget.color,
                  child: _chewieController != null
                      ? Chewie(controller: _chewieController!)
                      : const Center(child: CircularProgressIndicator()),
                ),
          if (!_isLoading && !widget.viewOnly && _chewieController != null)
            Center(
              child: IconButton(
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: widget.color,
                  size: 64.0,
                ),
                onPressed: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                    if (_isPlaying) {
                      _videoPlayerController?.play();
                    } else {
                      _videoPlayerController?.pause();
                    }
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
