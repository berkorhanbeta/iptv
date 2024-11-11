import 'dart:convert';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/model/iptv/iptv_model.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:video_player/video_player.dart';

class PlayerScreen extends StatefulWidget {
  final String? channel;
  PlayerScreen({super.key, required this.channel});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  IptvModel? channel;
  BetterPlayerController? _betterPlayerController;
  VideoPlayerController? _webVideoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    final channelParam = Get.parameters['channel'];
    channel = channelParam != null ? IptvModel.fromJson(jsonDecode(channelParam)) : null;

    if (channel == null || channel!.url == null) {
      print("Invalid channel URL");
      return;
    }

    if (kIsWeb) {
      // Initialize video player with Chewie for web
      _webVideoController = VideoPlayerController.networkUrl(Uri.parse(channel!.url!));
      _webVideoController!.initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _webVideoController!,
          aspectRatio: _webVideoController!.value.aspectRatio,
          autoPlay: true,
          looping: true,
          allowMuting: true,
          allowFullScreen: true,
          showControlsOnInitialize: true,
          autoInitialize: true,
          isLive: true
        );
        setState(() {});
      }).catchError((error) {
        print('Error initializing video player: $error');
      });
    } else {
      // Initialize BetterPlayer for non-web platforms
      final headers = {
        "Referer": channel!.referrer ?? '',
      };
      final betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        channel!.url!,
        videoFormat: BetterPlayerVideoFormat.hls,
        headers: channel!.referrer != null ? headers : null,
      );
      _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: true,
          allowedScreenSleep: false

        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      if (_chewieController == null || !_chewieController!.videoPlayerController.value.isInitialized) {
        return Scaffold(
          appBar: AppBar(title: Text('${channel!.name}')),
          body: Center(
            child: LoadingAnimationWidget.threeArchedCircle(
              color: Colors.yellow[300]!,
              size: 200,
            ),
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(title: Text('${channel!.name}')),
        body: AspectRatio(
          aspectRatio: _chewieController!.videoPlayerController.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text('${channel!.name}')),
        body: BetterPlayer(
          controller: _betterPlayerController!,
        ),
      );
    }
  }

  @override
  void dispose() {
    _webVideoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
