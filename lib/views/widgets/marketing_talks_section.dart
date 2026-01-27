import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/models/marketing_talk.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MarketingTalksSection extends StatefulWidget {
  final List<MarketingTalk> talks;

  const MarketingTalksSection({super.key, required this.talks});

  @override
  State<MarketingTalksSection> createState() => _MarketingTalksSectionState();
}

class _MarketingTalksSectionState extends State<MarketingTalksSection> {
  int? _playingTalkId;
  YoutubePlayerController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _playVideo(MarketingTalk talk) {
    final videoId = YoutubePlayer.convertUrlToId(talk.link);
    if (videoId == null) return;

    setState(() {
      _playingTalkId = talk.id;
      _controller?.dispose();
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.talks.isEmpty) return const SizedBox.shrink();

    final firstTalk = widget.talks.first;
    final List<MarketingTalk> remainingTalks = widget.talks.length > 1
        ? widget.talks.sublist(1, 3.clamp(0, widget.talks.length))
        : <MarketingTalk>[];

    if (_controller != null) {
      return YoutubePlayerBuilder(
        onEnterFullScreen: () {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        },
        onExitFullScreen: () {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        },
        player: YoutubePlayer(
          controller: _controller!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          onEnded: (meta) {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            setState(() {
              _playingTalkId = null;
              _controller?.dispose();
              _controller = null;
            });
          },
        ),
        builder: (context, player) {
          return _buildMainLayout(
            context,
            firstTalk,
            remainingTalks,
            player: player,
          );
        },
      );
    }

    return _buildMainLayout(context, firstTalk, remainingTalks);
  }

  Widget _buildMainLayout(
    BuildContext context,
    MarketingTalk firstTalk,
    List<MarketingTalk> remainingTalks, {
    Widget? player,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'MARKETING ',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
              TextSpan(
                text: 'TALKS',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'İş dünyasından en son haberleri ve videoları kanalımızdan izleyebilirsiniz',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        _buildTalkItem(context, firstTalk, isLarge: true, player: player),
        const SizedBox(height: 16),
        if (remainingTalks.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTalkItem(
                  context,
                  remainingTalks[0],
                  isLarge: false,
                  player: player,
                ),
              ),
              const SizedBox(width: 16),
              if (remainingTalks.length > 1)
                Expanded(
                  child: _buildTalkItem(
                    context,
                    remainingTalks[1],
                    isLarge: false,
                    player: player,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildTalkItem(
    BuildContext context,
    MarketingTalk talk, {
    required bool isLarge,
    Widget? player,
  }) {
    final isPlaying = _playingTalkId == talk.id;
    final height = isLarge ? 220.0 : 110.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          child: Container(
            width: double.infinity,
            height: height,
            color: Colors.black,
            child: isPlaying && player != null
                ? player
                : GestureDetector(
                    onTap: () => _playVideo(talk),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          talk.imageUrl,
                          width: double.infinity,
                          height: height,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: height,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported),
                              ),
                        ),
                        _buildPlayButton(isSmall: !isLarge),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          talk.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: isLarge ? 18 : 14,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPlayButton({bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 6 : 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        color: AppTheme.primaryColor,
        size: isSmall ? 28 : 44,
      ),
    );
  }
}
